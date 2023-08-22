#!/usr/bin/env ruby -w

require_relative "helper.rb"
require_relative "../lib/to_kill_a_mocking_lib"

class TestToKillAMockingLib < Minitest::Test
  def test_sanity__expect
    assert_mocha "expect(LHS).to receive(:a).with(:b).and_return(1)",
      "LHS.expects(:a).with(:b).returns(1)"
  end

  def test_sanity__allow
    assert_mocha "allow(LHS).to receive(:a).with(:b).and_return(1)",
      "LHS.stubs(:a).with(:b).returns(1)"
  end

  def test_sanity__allow_any
    assert_mocha "allow_any_instance_of(Foo).to receive(:a).and_return(1)",
      "Foo.any_instance.stubs(:a).returns(1)"
  end

  def test_sanity__expect_any
    assert_mocha "expect_any_instance_of(Foo).to receive(:a).and_return(1)",
      "Foo.any_instance.expects(:a).returns(1)"
  end

  def test_dunno1
    assert_mocha "allow(Rails).to receive(:logger).and_return(logger)",
      "Rails.stubs(:logger).returns(logger)"
  end

  def test_dunno2
    assert_mocha "expect(Rails.logger).to receive(:info).with('dunno')",
      "Rails.logger.expects(:info).with('dunno')"
  end

  def test_dunno3
    assert_mocha "expect(@brand.route).to receive(method)",
      "@brand.route.expects(method)"
  end

  def test_dunno4
    assert_mocha "expect(url_generator).to receive(:url).and_return(double('Url')).twice",
      "url_generator.expects(:url).returns(double('Url')).twice"
  end
end

# double(a: 1)                                             = stub(a: 1)
# double(a: 1)                                             = mock(a: 1)
# allow(foo).to receive(:a).and_return(1)                  = foo.stubs(:a).returns(1)
# expect(foo).to receive(:a).and_return(1)                 = foo.expects(:a).returns(1)
# allow_any_instance_of(Foo).to receive(:a).and_return(1)  = Foo.any_instance.stubs(:a).returns(1)
# expect_any_instance_of(Foo).to receive(:a).and_return(1) = Foo.any_instance.expects(:a).returns(1)

# RSpec                                     = Mocha
#
# double                                    = mock or stub
# instance_double                           = stub or mock.responds_like_instance_of
# expect().to receive().with().and_return() = mock.expects().with().returns()
# expect().not_to receive()                 = mock.expects().never
# expect()... and yield_control()           = mock.expects().yields(*parameters)
# expect()... and raise_error()             = mock.expects().raises(error)
# allow()...                                = Similar as above but substitute expects with stubs
# allow_any_instance_of.Klass               = Klass.any_instance.stubs
