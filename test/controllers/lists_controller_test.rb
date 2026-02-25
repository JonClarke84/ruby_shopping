require "test_helper"

class ListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @list = lists(:one)
  end

  test "should get home" do
    get root_url
    assert_response :success
  end

  test "should get show_current" do
    get current_list_tab_url
    assert_response :success
  end

  test "should get new" do
    get new_list_url
    assert_response :success
  end

  test "should create list" do
    assert_difference("List.count") do
      post lists_url, params: { list: { date: @list.date } }
    end

    assert_redirected_to current_list_tab_url
  end

  test "should show list" do
    get list_url(@list)
    assert_response :success
  end

  test "should update list" do
    patch list_url(@list), params: { list: { date: @list.date } }
    assert_redirected_to list_url(@list)
  end

  test "should destroy list" do
    assert_difference("List.count", -1) do
      delete list_url(@list)
    end

    assert_redirected_to root_url
  end
end
