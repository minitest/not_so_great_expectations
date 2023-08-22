# frozen_string_literal: true

module RuboCop
  module Cop
    module Minitest

      ##
      # Helps convert rspec mocks to mocha

      class ToKillAMockingLib < Base
        extend AutoCorrector
        include IgnoredNode

        attr_accessor :seen

        def initialize(config = nil, options = nil)
          super

          self.seen = {}
        end

        TOs = "{ :to :to_not :not_to }"
        def_node_matcher :receive?, "(send (send nil? $/^(?:expect|allow)(?:_any_instance_of)?$/ $_) $#{TOs} $`(send nil? :receive ...))"

        REPLACEMENTS = {
          :allow                  => :stubs,
          :allow_any_instance_of  => "any_instance.stubs",
          :and_return             => :returns,
          :expect                 => :expects,
          :expect_any_instance_of => "any_instance.expects",
          :to_not                 => :not_to,
          :with                   => :with,
        }
        REPLACEMENTS.default_proc = proc { |h,k| h[k] = k }

        def on_send node
          return if part_of_ignored_node? node

          receive?(node) { |exp_all, lhs, pos_neg, recv|
            ignore_node node

            bottom = recv
              .each_descendant(:send)
              .find { |n| n.method_name == :receive } || recv

            new_method = REPLACEMENTS[exp_all]
            raise "BAD: #{exp_all}" unless new_method

            bottom_args = bottom.loc.begin
              .join(bottom.loc.end)
              .source

            chain = bottom
              .each_ancestor(:send)
              .take_while { |n| n != node }
              .map { |n|
                b = n.loc.begin
                e = n.loc.end
                a = b.join(e).source if b && e
                m = REPLACEMENTS[n.method_name]

                ".%s%s" % [m, a]
              }
              .join

            extra = ".never" if REPLACEMENTS[pos_neg] == :not_to

            replacement = "%s.%s%s%s%s" % [lhs.source,
                                           new_method,
                                           bottom_args,
                                           chain,
                                           extra]

            message = "Use `mocha` instead."

            add_offense(node, message: message) do |corrector|
              corrector.replace(node, replacement)
            end

            return
          }
        end
      end
    end
  end
end
