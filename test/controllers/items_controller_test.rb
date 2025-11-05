require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "index should work without list_id parameter" do
    get items_path
    assert_response :success
    assert_select "h1"
  end

  test "create should require list_id parameter" do
    list = lists(:one)
    post list_items_path(list), params: { item: { name: "Milk", quantity: 1 } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
end
