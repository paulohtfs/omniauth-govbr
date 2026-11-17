# frozen_string_literal: true

require "test_helper"

class GovbrTest < Test::Unit::TestCase
  test "has a version number" do
    assert_match(/\A\d+\.\d+\.\d+/, OmniAuth::Govbr::VERSION)
  end

  test "loads the govbr strategy" do
    assert(defined?(OmniAuth::Strategies::Govbr))
  end

  test "does not define a separate Omniauth namespace" do
    assert_false(Object.const_defined?(:Omniauth))
  end

  test "can be required by the gem name" do
    assert_nothing_raised { require "omniauth-govbr" }
  end
end
