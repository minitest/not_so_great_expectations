#!/usr/bin/env ruby -w

require_relative "helper.rb"
require_relative "../lib/not_so_great_expectations"

class TestNotSoGreatExpectations < Minitest::Test
  make_my_diffs_pretty!

  def test_must_be__operator__naked
    assert_cop "expr.must_be :>=, 42", "assert_operator expr, :>=, 42"
  end

  def test_must_be__operator
    assert_cop "_(expr).must_be :>=, 42", "assert_operator expr, :>=, 42"
  end

  def test_must_be__predicate
    assert_cop "_(expr).must_be :even?", "assert_predicate expr, :even?"
  end

  def test_must_be_close_to
    assert_cop "_(expr).must_be_close_to 42", "assert_in_delta 42, expr"
  end

  def test_must_be_empty
    assert_cop "_(expr).must_be_empty", "assert_empty expr"
  end

  def test_must_be_empty__naked
    assert_cop "expr.must_be_empty", "assert_empty expr"
  end

  def test_must_be_instance_of
    assert_cop "_(expr).must_be_instance_of X", "assert_instance_of X, expr"
  end

  def test_must_be_kind_of
    assert_cop "_(expr).must_be_kind_of X", "assert_kind_of X, expr"
  end

  def test_must_be_nil
    assert_cop "_(expr).must_be_nil", "assert_nil expr"
  end

  def test_must_be_same_as
    assert_cop "_(expr).must_be_same_as X", "assert_same X, expr"
  end

  def test_must_be_silent
    assert_cop "_{expr}.must_be_silent", "assert_silent { expr }"

    skip "not yet"
    assert_cop <<~'RUBY', "assert_silent do\n expr \n end"
      _{
        expr + \
          42
       }.must_be_silent
    RUBY
  end

  def test_must_be_within_delta
    assert_cop "_(expr).must_be_within_delta 42", "assert_in_delta 42, expr"
  end

  def test_must_be_within_epsilon
    assert_cop "_(expr).must_be_within_epsilon 42", "assert_in_epsilon 42, expr"
  end

  def test_must_equal
    assert_cop "expect(expr).must_equal 42", "assert_equal 42, expr"

    # but does NOT correct what rubocop-minitest corrects:
    assert_cop "expect(expr).must_equal nil", "assert_equal nil, expr"
  end

  def test_must_include
    assert_cop "_(expr).must_include X", "assert_includes expr, X"
  end

  def test_must_match
    assert_cop "_(expr).must_match X", "assert_match X, expr"
  end

  def test_must_output
    assert_cop "_{expr}.must_output O, E", "assert_output(O, E) { expr }"
    assert_cop "_{expr}.must_output O", "assert_output(O) { expr }"
  end

  def test_must_pattern_match
    assert_cop "_{expr}.must_pattern_match X", "assert_pattern(X) { expr }"
  end

  def test_must_raise
    assert_cop "_{expr}.must_raise X", "assert_raises(X) { expr }"
  end

  def test_must_respond_to
    assert_cop "_(expr).must_respond_to :x", "assert_respond_to expr, :x"
  end

  def test_must_throw
    assert_cop "_{expr}.must_throw X", "assert_throws(X) { expr }"
  end

  def test_path_must_exist
    assert_cop "_(expr).path_must_exist", "assert_path_exists expr"
  end

  def test_path_wont_exist
    assert_cop "_(expr).path_wont_exist", "refute_path_exists expr"
  end

  def test_wont_be__operator
    assert_cop "_(expr).wont_be :>=, 42", "refute_operator expr, :>=, 42"
  end

  def test_wont_be__predicate
    assert_cop "_(expr).wont_be :even?", "refute_predicate expr, :even?"
  end

  def test_wont_be_close_to
    assert_cop "_(expr).wont_be_close_to 42", "refute_in_delta 42, expr"
  end

  def test_wont_be_empty
    assert_cop "_(expr).wont_be_empty", "refute_empty expr"
  end

  def test_wont_be_instance_of
    assert_cop "_(expr).wont_be_instance_of X", "refute_instance_of X, expr"
  end

  def test_wont_be_kind_of
    assert_cop "_(expr).wont_be_kind_of X", "refute_kind_of X, expr"
  end

  def test_wont_be_nil
    assert_cop "_(expr).wont_be_nil", "refute_nil expr"
  end

  def test_wont_be_same_as
    assert_cop "_(expr).wont_be_same_as X", "refute_same X, expr"
  end

  def test_wont_be_within_delta
    assert_cop "_(expr).wont_be_within_delta 42", "refute_in_delta 42, expr"
  end

  def test_wont_be_within_epsilon
    assert_cop "_(expr).wont_be_within_epsilon 42", "refute_in_epsilon 42, expr"
  end

  def test_wont_equal
    assert_cop "_(expr).wont_equal X", "refute_equal X, expr"
  end

  def test_wont_include
    assert_cop "_(expr).wont_include X", "refute_includes expr, X"
  end

  def test_wont_match
    assert_cop "_(expr).wont_match X", "refute_match X, expr"
  end

  def test_wont_pattern_match
    assert_cop "_{expr}.wont_pattern_match X", "refute_pattern(X) { expr }"
  end

  def test_wont_respond_to
    assert_cop "_(expr).wont_respond_to :x", "refute_respond_to expr, :x"
  end

  def test_assert_arity
    assert_cop_raises ArgumentError, "_(expr).wont_equal X, Y, OOPS"
  end
end
