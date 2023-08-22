# frozen_string_literal: true

# rubocop:disable Style, Lint/MissingCopEnableDirective

module RuboCop
  module Cop
    module Minitest
      VERSION = "1.0.0a1"

      ##
      # Checks for deprecated global expectations
      # and autocorrects them to use expect format.
      #
      # @example
      #
      #   # very bad
      #   musts.must_equal expected_musts
      #   wonts.wont_match expected_wonts
      #   proc { musts }.must_raise TypeError
      #
      #   # bad
      #   _(musts).must_equal expected_musts
      #   _(wonts).wont_match expected_wonts
      #   _ { musts }.must_raise TypeError
      #
      #   expect(musts).must_equal expected_musts
      #   expect(wonts).wont_match expected_wonts
      #   expect { musts }.must_raise TypeError
      #
      #   value(musts).must_equal expected_musts
      #   value(wonts).wont_match expected_wonts
      #   value { musts }.must_raise TypeError
      #
      #   # good
      #   assert_equal expected_musts, musts
      #   refute_match expected_wonts, wonts
      #   assert_raises(TypeError) { musts }

      class NotSoGreatExpectations < Base
        # include ConfigurableEnforcedStyle
        extend AutoCorrector

        EXPECTATION = {
          :must_be                => :assert_operator,
          :must_be_close_to       => :assert_in_delta,
          :must_be_empty          => :assert_empty,
          :must_be_instance_of    => :assert_instance_of,
          :must_be_kind_of        => :assert_kind_of,
          :must_be_nil            => :assert_nil,
          :must_be_same_as        => :assert_same,
          :must_be_silent         => :assert_silent,
          :must_be_within_delta   => :assert_in_delta,
          :must_be_within_epsilon => :assert_in_epsilon,
          :must_equal             => :assert_equal,
          :must_include           => :assert_includes,
          :must_match             => :assert_match,
          :must_output            => :assert_output,
          :must_pattern_match     => :assert_pattern,
          :must_raise             => :assert_raises,
          :must_respond_to        => :assert_respond_to,
          :must_throw             => :assert_throws,
          :path_must_exist        => :assert_path_exists,
          :path_wont_exist        => :refute_path_exists,
          :wont_be                => :refute_operator,
          :wont_be_close_to       => :refute_in_delta,
          :wont_be_empty          => :refute_empty,
          :wont_be_instance_of    => :refute_instance_of,
          :wont_be_kind_of        => :refute_kind_of,
          :wont_be_nil            => :refute_nil,
          :wont_be_same_as        => :refute_same,
          :wont_be_within_delta   => :refute_in_delta,
          :wont_be_within_epsilon => :refute_in_epsilon,
          :wont_equal             => :refute_equal,
          :wont_include           => :refute_includes,
          :wont_match             => :refute_match,
          :wont_pattern_match     => :refute_pattern,
          :wont_respond_to        => :refute_respond_to,
        }

        BINARY = [
          :assert_equal,
          :assert_in_delta,
          :assert_in_epsilon,
          :assert_instance_of,
          :assert_kind_of,
          :assert_match,
          :assert_same,
          :refute_equal,
          :refute_in_delta,
          :refute_in_epsilon,
          :refute_instance_of,
          :refute_kind_of,
          :refute_match,
          :refute_same,
        ]

        UNARY = [
          :assert_empty,
          :assert_nil,
          :assert_path_exists,

          :refute_empty,
          :refute_nil,
          :refute_path_exists,
        ]

        SPECIAL = [
          :assert_includes,
          :assert_operator,
          :assert_respond_to,

          :refute_includes,
          :refute_operator,
          :refute_respond_to,
        ]

        BLOCK = [
          :assert_output,
          :assert_pattern,
          :assert_raises,
          :assert_silent,
          :assert_throws,

          :refute_pattern,
        ].group_by(&:itself)

        DSL_METHODS = %i[_ expect value].freeze

        def on_send node
          register_offense node if expectation? node
        end

        def_node_matcher :expectation?, <<~PATTERN
          { #plain_expectation? #block_expectation? #naked_expectation? }
        PATTERN

        def_node_matcher :plain_expectation?, <<~PATTERN
          (send (send nil? $#dsl_method? _) $#expectation_method? ...)
        PATTERN

        def_node_matcher :block_expectation?, <<~PATTERN
          (send (block (send nil? $#dsl_method?) ...) $#expectation_method? ...)
        PATTERN

        def_node_matcher :naked_expectation?, <<~PATTERN
          (send _ $#expectation_method? ...)
        PATTERN

        def dsl_method? method
          DSL_METHODS.include? method
        end

        def expectation_method? method
          EXPECTATION.key? method
        end

        def assert_arity ary, size
          return if size === ary.size
          raise ArgumentError, "bad number of arguments %p: %p" % [size, ary]
        end

        def wrap msg, *args
          lhs = args.first

          fmt =
            case #                 { ... }.to_json is a CALL, not hash_type
            when lhs.hash_type? || lhs.source.start_with?("{") then
              if lhs.source.start_with?("{") then
                "%s(%s)"
              else
                rest = args.drop(1)
                return "%s({ %s }, %s)" % [msg, lhs.source, rest.map(&:source).join(", ")]
              end
            when lhs.regexp_type? then
              "%s(%s)"
            else
              "%s %s"
            end

          fmt % [msg, args.map(&:source).join(", ")]
        end

        def plain_replacement msg, *args
          case msg
          when *BINARY then
            assert_arity args, 2..3
            lhs, rhs, *rest = args
            wrap msg, rhs, lhs, *rest
          when :assert_operator, :refute_operator then # specialization
            assert_arity args, 2..4
            @repl_msg = msg = msg == :assert_operator ? :assert_predicate : :refute_predicate if
              args.size == 2
            wrap msg, *args
          when *SPECIAL then
            assert_arity args, 2..3
            wrap msg, *args
          when *UNARY then
            assert_arity args, 1..2
            wrap msg, *args
          else
            raise "Unhandled assertion: %p. Please file bug" % [msg]
          end
        end

        def block_replacement msg, args, body, oneliner
          raise "Unhandled assertion: %p. Please file bug" % [msg] unless
            BLOCK.key? msg

          assert_arity args, 0..2
          exp, *rest = args

          # TODO: fuuuuck do multi-line and indent properly. IDGAF right now
          if oneliner then
            if rest.empty? then
              if exp then
                "%s(%s) { %s }" % [msg, exp.source, body.map(&:source).join("\n")]
              else
                "%s { %s }" % [msg, body.map(&:source).join("\n")]
              end
            else
              rest = rest.map(&:source).join(", ")
              "%s(%s, %s) { %s }" % [msg, exp.source, rest, body.map(&:source).join("\n")]
            end
          else
            if rest.empty? then
              if exp then
                "%s %s do %s end" % [msg, exp.source, body.map(&:source).join("\n")]
              else
                "%s do %s end" % [msg, body.map(&:source).join("\n")]
              end
            else
              rest = rest.map(&:source).join(", ")
              "%s %s, %s do %s end" % [msg, exp.source, rest, body.map(&:source).join("\n")]
            end
          end
        end

        def register_offense node
          @repl_msg = nil

          replacement =
            case node # rubocop:disable Rubycw/Rubycw
            in [:send, [:send, _, _, lhs], msg, *rest]
              self.plain_replacement EXPECTATION[msg], lhs, *rest
            in [:send, [:block, [:send, _, _], _, *body], msg, *rest]
              self.block_replacement EXPECTATION[msg], rest, body, node.single_line?
            in [:send, lhs, msg, *rest]
              self.plain_replacement EXPECTATION[msg], lhs, *rest
            else
              raise "Unknown expectation structure: %p. Please file bug" % [node]
            end

          message = "Use `%s` instead." % [@repl_msg || EXPECTATION[msg]]

          add_offense(node, message: message) do |corrector|
            corrector.replace(node, replacement)
          end
        end
      end
    end
  end
end
