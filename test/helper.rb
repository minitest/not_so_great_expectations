require_relative "rubocop_subset"
require "minitest/autorun"
require_relative "assert_offense"

module RuboCop::Minitest::AssertOffense
  def refute_cop(source, file = nil) # was assert_no_offenses
    setup_assertion

    offenses = inspect_source(source, @cop, file)

    expected_annotations = RuboCop::RSpec::ExpectOffense::AnnotatedSource.parse(source)
    actual_annotations = expected_annotations.with_offense_annotations(offenses)

    assert_equal(source, actual_annotations.to_s)
  end

  def assert_cop bad, good, msg: nil
    chevrons = "^" * bad.lines.first.length

    message = msg || good[/(?:assert|refute|must|wont)\w*/]

    full_bad = "%s\n%s Use `%s` instead.\n" % [bad, chevrons, message]

    assert_offense full_bad

    if good then
      assert_correction "#{good}\n"
    else
      assert_no_corrections
    end
  end

  def assert_cop_raises exc, src
    assert_raises exc do
      assert_cop src, "expected doesn't matter here"
    end
  end

  def assert_mocha bad, good
    assert_cop bad, good, msg: :mocha
  end
end

Minitest::Test.include RuboCop::Minitest::AssertOffense
