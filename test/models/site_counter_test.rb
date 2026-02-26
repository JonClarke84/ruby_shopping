require "test_helper"

class SiteCounterTest < ActiveSupport::TestCase
  test "increment creates counter if it doesn't exist" do
    assert_difference "SiteCounter.count", 1 do
      SiteCounter.increment!(:home_visits)
    end

    assert_equal 1, SiteCounter.count_for(:home_visits)
  end

  test "increment increases existing counter" do
    SiteCounter.create!(name: "home_visits", value: 5)

    assert_no_difference "SiteCounter.count" do
      SiteCounter.increment!(:home_visits)
    end

    assert_equal 6, SiteCounter.count_for(:home_visits)
  end

  test "count_for returns 0 for non-existent counter" do
    assert_equal 0, SiteCounter.count_for(:nonexistent)
  end
end
