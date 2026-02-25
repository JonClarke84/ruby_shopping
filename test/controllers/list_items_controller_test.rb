require "test_helper"

class ListItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @list = lists(:one)
    @list_item = list_items(:one)
    @other_list = lists(:two)
  end

  test "should toggle list item" do
    patch toggle_list_list_item_url(@list, @list_item), params: { ticked: true }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert json_response["ticked"]

    @list_item.reload
    assert @list_item.ticked
  end

  test "should toggle list item to false" do
    @list_item.update(ticked: true)

    patch toggle_list_list_item_url(@list, @list_item), params: { ticked: false }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_not json_response["ticked"]

    @list_item.reload
    assert_not @list_item.ticked
  end

  test "should update list item quantity" do
    patch list_list_item_url(@list, @list_item), params: { quantity: 5 }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal 5, json_response["quantity"]

    @list_item.reload
    assert_equal 5, @list_item.quantity
  end

  test "should not update list item with invalid quantity" do
    patch list_list_item_url(@list, @list_item), params: { quantity: 0 }, as: :json
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
  end

  test "should destroy list item" do
    assert_difference("ListItem.count", -1) do
      delete list_list_item_url(@list, @list_item)
    end

    assert_redirected_to current_list_tab_path
  end

  test "should not allow access to list items from different group" do
    # Create a list in a different group
    different_group = groups(:two)
    different_list = List.create!(date: Date.today, group: different_group)
    different_item = Item.create!(name: "Different Item", group: different_group)
    different_list_item = ListItem.create!(list: different_list, item: different_item, quantity: 1)

    # Try to toggle the list item from a different group
    patch toggle_list_list_item_url(different_list, different_list_item), params: { ticked: true }, as: :json
    assert_redirected_to current_list_tab_path
    assert_equal "You don't have access to that list", flash[:alert]
  end

  test "should not allow update to list items from different group" do
    # Create a list in a different group
    different_group = groups(:two)
    different_list = List.create!(date: Date.today, group: different_group)
    different_item = Item.create!(name: "Different Item", group: different_group)
    different_list_item = ListItem.create!(list: different_list, item: different_item, quantity: 1)

    # Try to update the list item from a different group
    patch list_list_item_url(different_list, different_list_item), params: { quantity: 5 }, as: :json
    assert_redirected_to current_list_tab_path
    assert_equal "You don't have access to that list", flash[:alert]
  end

  test "should not allow delete of list items from different group" do
    # Create a list in a different group
    different_group = groups(:two)
    different_list = List.create!(date: Date.today, group: different_group)
    different_item = Item.create!(name: "Different Item", group: different_group)
    different_list_item = ListItem.create!(list: different_list, item: different_item, quantity: 1)

    # Try to delete the list item from a different group
    assert_no_difference("ListItem.count") do
      delete list_list_item_url(different_list, different_list_item)
    end

    assert_redirected_to current_list_tab_path
    assert_equal "You don't have access to that list", flash[:alert]
  end
end
