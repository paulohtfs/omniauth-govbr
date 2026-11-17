# frozen_string_literal: true

require "test_helper"

module Omniauth
  class GovbrTest < Test::Unit::TestCase
    test "has a version number" do
      assert_match(/\A\d+\.\d+\.\d+/, ::Omniauth::Govbr::VERSION)
    end

    test "loads the govbr strategy" do
      assert(defined?(::OmniAuth::Strategies::Govbr))
    end
  end
end
