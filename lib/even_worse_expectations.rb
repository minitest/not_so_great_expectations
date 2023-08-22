# frozen_string_literal: true

class RuboCop::AST::Node
  def to_pat
    self.to_s.split.join(" ").gsub(/\bnil\b/, "nil?")
  end

  def where
    self.source_range.to_s.delete_prefix "#{Dir.pwd}/"
  end
end

module RuboCop
  module Cop
    module Minitest

      ##
      # Helps convert rspec to minitest

      class EvenWorseExpectations < Base
        extend AutoCorrector

        attr_accessor :seen

        def initialize(config = nil, options = nil)
          super

          self.seen = {}
        end

        def inspect
          "RuboCop::Cop::Minitest::EvenWorseExpectations"
        end

        def on_send node
          if minitest_expectation? node then
            seen[node] = true
            return
          end

          to_be_OP_expectation?(node)          { |*ms| return register_be_OP_offense node, ms }
          to_be_X_expectation?(node)           { |*ms| return register_offense node, ms }
          to_be_expectation?(node)             { |*ms| return register_be_offense node, ms }
          to_eq_expectation?(node)             { |*ms| return register_offense node, ms }
          to_include_expectation?(node)        { |*ms| return register_offense node, ms }
          to_match_expectation?(node)          { |*ms| return register_offense node, ms }
          to_be_within_expectation?(node)      { |*ms| return register_offense node, ms }
          to_raise_expectation?(node)          { |*ms| return register_raise node, ms }
          to_receive_expectation?(node)        { |*ms| seen[node] = true; return }
          to_yield_control?(node)              { |*ms| seen[node] = true; return }

          return if seen[node] || seen[node&.parent] || seen[node&.parent&.parent]

          if missed_expectation?(node) then
            require "pry"; binding.pry if ENV["DDD"]
            puts; p unmatched: node.source, pat: node.parent.to_pat, where: node.where
          end
        end

        exp_mt_call  = "(send        (send nil? :expect  ...) /^(?:must|wont)_/ ...)"
        exp_mt_block = "(send (block (send nil? :expect) ...) /^(?:must|wont)_/ ...)"
        exp_minitest = [ "{", exp_mt_call, exp_mt_block, "}" ].join " "

        def_node_matcher :minitest_expectation?, exp_minitest

        TOs = "{ :to :to_not :not_to }"

        exp = ->(name) {
          "(send (send nil? :expect $_) $#{TOs} (send nil? $%s $...) $str ?)" %
            [String === name ? name : name.inspect]
        }

        def_node_matcher :to_be_OP_expectation?,    "(send (send nil? :expect $_) $#{TOs} (send (send nil? :be) ${ :== :!= :< :> :<= :>= :=~ :!~ :<=> :=== :!== } $...))"

        def_node_matcher :to_be_X_expectation?,     exp[/^(be|have)_\w+$/]

        def_node_matcher :to_be_expectation?,       "(send (send nil? :expect $_) $#{TOs} `(send nil? $:be $...))" # exp[:be]
        def_node_matcher :to_eq_expectation?,       exp[:eq]
        def_node_matcher :to_include_expectation?,  exp[:include]
        def_node_matcher :to_match_expectation?,    exp[:match]
        def_node_matcher :to_be_within_expectation?, "(send (send nil? :expect $_) $#{TOs} (send (send nil? $/^(?:be_)?within/ $_) :of $_))"

        exp_raise = "(send $(block (send nil? :expect) _ ...) $:to (send nil? :raise_error $...))"
        def_node_matcher :to_raise_expectation?,    exp_raise


        def_node_matcher :to_receive_expectation?, "(send (send nil? $/^(?:expect|allow)(?:_any_instance_of)?$/ $_) $#{TOs} $`(send nil? :receive ...))"
        def_node_matcher :to_yield_control?, "(send (block (send nil? :expect) args ...) $#{TOs} (send nil? :yield_control))"

        def_node_matcher :missed_expectation?,      "(send nil? /^(?:expect|allow)(?:_any_instance_of)?$/ ...)"

        REPLACEMENTS = {
          :to => {
            :be_a           => :must_be_kind_of,
            :be_a_kind_of   => :must_be_kind_of,
            :be_instance_of => :must_be_instance_of,
            :be_kind_of     => :must_be_kind_of,
            :be_nil         => :must_be_nil,
            :eq             => :must_equal,
            :include        => :must_include,
            :match          => :must_match,
            :within         => :must_be_within_delta,
            :be_within      => :must_be_within_delta,
          },

          :to_not => {
            :be_a           => :wont_be_kind_of,
            :be_a_kind_of   => :wont_be_kind_of,
            :be_instance_of => :wont_be_instance_of,
            :be_kind_of     => :wont_be_kind_of,
            :be_nil         => :wont_be_nil,
            :eq             => :wont_equal,
            :include        => :wont_include,
            :match          => :wont_match,
            :within         => :wont_be_within_delta,
            :be_within      => :wont_be_within_delta,
          },
        }
        REPLACEMENTS[:not_to] = REPLACEMENTS[:to_not]

        MUST_BE = { to: :must_be, to_not: :wont_be }
        MUST_BE[:not_to]      = MUST_BE[:to_not]

        def register_offense node, matches
          seen[node] = true

          lhs, pos_neg, msg, args, opt_msg, *wtf = matches

          raise ArgumentError, "bad matches: %p" % [matches] unless
            wtf.empty?

          replacement_msg = REPLACEMENTS.dig(pos_neg, msg)

          replacement =
            case replacement_msg
            when nil
              replacement_msg = MUST_BE[pos_neg] # TODO: also predicate?

              case msg
              when /^be_(\w+)/ then
                if args.empty? then
                  "expect(%s).%s :%s?" % [lhs.source, replacement_msg, $1]
                else
                  "expect(%s).%s :%s?, %s" % \
                    [lhs.source, replacement_msg, $1, args.first.source]
                end
              when /^have_(\w+)/ then
                if args.empty? then
                  "expect(%s).%s :has_%s?" % [lhs.source, replacement_msg, $1]
                else
                  "expect(%s).%s :has_%s?, %s" % \
                    [lhs.source, replacement_msg, $1, args.first.source]
                end
              end
            when /within/ then
              # TODO: optional message? does this happen?
              act, pos_neg, msg, n, exp = matches

              "expect(%s).%s %s" % \
                [act.source, replacement_msg, [exp, n].map(&:source).join(", ")]
            else
              if args.empty? then
                "expect(%s).%s" % [lhs.source, replacement_msg]
              else
                "expect(%s).%s %s" % \
                  [lhs.source, replacement_msg, args.map(&:source).join(", ")]
              end
            end

          unless replacement then
            require "pry"; binding.pry if ENV["DDD"]
            p unknown: [pos_neg, msg]
            return
          end

          message = "Use `%s` instead." % [replacement_msg]

          add_offense(node, message: message) do |corrector|
            corrector.replace(node, replacement)
          end
        end

        def register_raise node, ms
          body, _pos_neg, args = ms

          seen[body] = true

          message     = "Use `must_raise` instead."
          replacement = "%s.must_raise %s" % \
            [body.source, args.map(&:source).join(", ")]

          add_offense(node, message: message) do |corrector|
            corrector.replace(node, replacement)
          end
        end

        BE_VERBS = { to: :must_be_same_as, to_not: :wont_be_same_as }

        def register_be_offense node, ms
          lhs, pos_neg, _be, args = ms

          seen[lhs.parent] = true

          verb = { # REFACTOR: lift
                  :to => {
                    s(:true)  => "assert",
                    s(:false) => "refute",
                  },
                  :to_not => {
                    s(:false) => "assert",
                    s(:true)  => "refute",
                  },
                  :not_to => {
                    s(:false) => "assert",
                    s(:true)  => "refute",
                  },
                 }.dig(pos_neg, args.first)

          replacement = if verb then
                          "%s %s" % [verb, lhs.source]
                        else
                          verb = BE_VERBS[pos_neg]
                          args_src = args.map(&:source).join(", ")
                          "expect(%s).%s %s" % [lhs.source, verb, args_src]
                        end

          message = "Use `%s` instead." % [verb]

          add_offense(node, message: message) do |corrector|
            corrector.replace(node, replacement)
          end
        end

        def register_be_OP_offense node, ms
          seen[node] = true
          lhs, pos_neg, sub_msg, args = ms

          msg = MUST_BE[pos_neg]

          replacement = "expect(%s).%s %p, %s" % [lhs.source, msg, sub_msg, args.first.source]

          message = "Use `%s` instead." % [msg]

          add_offense(node, message: message) do |corrector|
            corrector.replace(node, replacement)
          end
        end
      end
    end
  end
end
