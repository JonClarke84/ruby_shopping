require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home without authentication" do
    get root_url
    assert_response :success
  end

  test "home page contains link to shopping app" do
    get root_url
    assert_select "a[href=?]", "/shopping/"
  end

  test "home page increments visitor counter" do
    assert_difference "SiteCounter.count_for(:home_visits)", 1 do
      get root_url
    end
  end

  test "home page displays visitor count" do
    3.times { get root_url }
    assert_select ".visitor-counter", text: "000003"
  end

  test "should get about without authentication" do
    get about_url
    assert_response :success
  end

  test "should get links without authentication" do
    get links_url
    assert_response :success
  end

  test "should get apps without authentication" do
    get apps_url
    assert_response :success
  end

  test "should get guestbook without authentication" do
    get guestbook_url
    assert_response :success
  end

  test "should create guestbook entry" do
    assert_difference "GuestbookEntry.count", 1 do
      post guestbook_url, params: { guestbook_entry: { name: "Test Visitor", message: "Great site!" } }
    end

    assert_redirected_to guestbook_url
    follow_redirect!
    assert_select ".guestbook-entry", count: 1
  end

  test "should not create guestbook entry with blank name" do
    assert_no_difference "GuestbookEntry.count" do
      post guestbook_url, params: { guestbook_entry: { name: "", message: "Great site!" } }
    end

    assert_response :unprocessable_entity
  end

  test "should not create guestbook entry with blank message" do
    assert_no_difference "GuestbookEntry.count" do
      post guestbook_url, params: { guestbook_entry: { name: "Test", message: "" } }
    end

    assert_response :unprocessable_entity
  end
end
