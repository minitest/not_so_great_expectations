#!/usr/bin/env ruby -w

require_relative "helper.rb"
require_relative "../lib/even_worse_expectations"

class TestEvenWorseExpectations < Minitest::Test
  def test_inspect
    assert_equal "RuboCop::Cop::Minitest::EvenWorseExpectations", @cop.inspect
  end

  def test_expect_to_be
    assert_cop "expect(expr).to be >= 42", "expect(expr).must_be :>=, 42"
  end

  def test_expect_to_not_be
    assert_cop "expect(expr).to_not be >= 42", "expect(expr).wont_be :>=, 42"
    assert_cop "expect(expr).not_to be >= 42", "expect(expr).wont_be :>=, 42"
    # TODO :to_be_OP_expectation?,    "(send (send nil? :expect $_) $#{TOs} (send (send nil? :be) ${ :== :!= :< :> :<= :>= :=~ :!~ :<=> :=== :!== } $...))"
  end

  def test_expect_to_be__pred
    assert_cop "expect(expr).to be_x", "expect(expr).must_be :x?"
  end

  def test_expect_to_be__pred_oper
    assert_cop "expect(expr).to be_x(42)", "expect(expr).must_be :x?, 42"
  end

  def test_expect_to_be__have
    assert_cop "expect(expr).to have_x", "expect(expr).must_be :has_x?"
  end

  def test_expect_to_be__have_oper
    assert_cop "expect(expr).to have_x(42)", "expect(expr).must_be :has_x?, 42"
  end

  def test_expect_to_not_be__pred
    assert_cop "expect(expr).to_not be_x", "expect(expr).wont_be :x?"
    assert_cop "expect(expr).not_to be_x", "expect(expr).wont_be :x?"
  end

  def test_expect_to_not_be__pred_oper
    assert_cop "expect(expr).to_not be_x(42)", "expect(expr).wont_be :x?, 42"
    assert_cop "expect(expr).not_to be_x(42)", "expect(expr).wont_be :x?, 42"
  end

  def test_expect_to_not_be__have
    assert_cop "expect(expr).to_not have_x", "expect(expr).wont_be :has_x?"
    assert_cop "expect(expr).not_to have_x", "expect(expr).wont_be :has_x?"
  end

  def test_expect_to_not_be__have_oper
    assert_cop "expect(expr).to_not have_x(42)", "expect(expr).wont_be :has_x?, 42"
    assert_cop "expect(expr).not_to have_x(42)", "expect(expr).wont_be :has_x?, 42"
  end

  def test_expect_to__be_a
    assert_cop "expect(expr).to be_a X", "expect(expr).must_be_kind_of X"
  end

  def test_expect_to__be_a_kind_of
    assert_cop "expect(expr).to be_a_kind_of X", "expect(expr).must_be_kind_of X"
  end

  def test_expect_to__be_instance_of
    assert_cop "expect(expr).to be_instance_of X", "expect(expr).must_be_instance_of X"
  end

  def test_expect_to__be_kind_of
    assert_cop "expect(expr).to be_kind_of X", "expect(expr).must_be_kind_of X"
  end

  def test_expect_to__be_nil
    assert_cop "expect(expr).to be_nil", "expect(expr).must_be_nil"
  end

  def test_expect_to__be_nil_arg
    assert_cop "expect(expr).to be(nil)", "expect(expr).must_be_same_as nil"
  end

  def test_expect_to__be__other
    assert_cop "expect(expr).to be(X)", "expect(expr).must_be_same_as X"
  end

  def test_expect_to_not__be__other
    assert_cop "expect(expr).to_not be(X)", "expect(expr).wont_be_same_as X"
  end

  def test_expect_to__be_true
    skip
    assert_cop "expect(expr).to be_true", "expect(!!expr).must_equal true"
  end

  def test_expect_to__be_false
    skip
    assert_cop "expect(expr).to be_false", "expect(!!expr).must_equal false"
  end

  def test_expect_to__be_true_arg
    assert_cop "expect(expr).to be(true)", "assert expr"
  end

  def test_expect_to__be_false_arg
    assert_cop "expect(expr).to be(false)", "refute expr"
  end

  def test_expect_to__be_within # OMFG
    exp = "expect(act).must_be_within_delta exp, n"
    assert_cop "expect(act).to be_within(n).of(exp)", exp
    assert_cop "expect(act).to    within(n).of(exp)", exp
  end

  def test_expect_to__eq
    assert_cop "expect(expr).to eq X", "expect(expr).must_equal X"
  end

  def test_expect_to__eq_msg
    assert_cop "expect(act).to eq(exp), 'msg'", "expect(act).must_equal exp, 'msg'"
  end

  def test_expect_to__include
    assert_cop "expect(expr).to include X", "expect(expr).must_include X"
  end

  def test_expect_to__match
    assert_cop "expect(expr).to match X", "expect(expr).must_match X"
  end

  def test_expect_to_not__be_a
    assert_cop "expect(expr).to_not be_a X", "expect(expr).wont_be_kind_of X"
  end

  def test_expect_to_not__be_a_kind_of
    assert_cop "expect(expr).to_not be_a_kind_of X", "expect(expr).wont_be_kind_of X"
  end

  def test_expect_to_not__be_instance_of
    assert_cop "expect(expr).to_not be_instance_of X", "expect(expr).wont_be_instance_of X"
  end

  def test_expect_to_not__be_kind_of
    assert_cop "expect(expr).to_not be_kind_of X", "expect(expr).wont_be_kind_of X"
  end

  def test_expect_to_not__be_nil
    assert_cop "expect(expr).to_not be_nil", "expect(expr).wont_be_nil"
  end

  def test_expect_to_not__be_nil_arg
    skip
    assert_cop "expect(expr).to_not be(nil)", "assert(expr).wont_be_same_as nil"
  end

  def test_expect_to_not__be_true
    skip
    assert_cop "expect(expr).to_not be_true", "expect(!!expr).wont_equal true"
  end

  def test_expect_to_not__be_true_arg
    assert_cop "expect(expr).to_not be(true)", "refute expr"
  end

  def test_expect_to_not__be_false
    skip
    assert_cop "expect(expr).to_not be_false", "expect(!!expr).must_equal false"
  end

  def test_expect_to_not__be_false_arg
    assert_cop "expect(expr).to_not be(false)", "assert expr"
  end

  def test_expect_to_not__eq
    assert_cop "expect(expr).to_not eq X", "expect(expr).wont_equal X"
  end

  def test_expect_to_not__include
    assert_cop "expect(expr).to_not include X", "expect(expr).wont_include X"
  end

  def test_expect_to_not__match
    assert_cop "expect(expr).to_not match X", "expect(expr).wont_match X"
  end

  def test_expect_to__raise
    assert_cop "expect { expr }.to raise_error X", "expect { expr }.must_raise X"
  end

  def test_expect_to_not__raise
    assert_output(/:unmatched/) do
      refute_cop "expect { expr }.to_not raise_error" # TODO: properly error
    end
  end
end
