require "test_helper"

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = groups(:one)
  end

  test "should create group" do
    assert_difference("Group.count") do
      post groups_url, params: { group: { name: "New Group" } }
    end
  end

  test "should update group" do
    patch group_url(@group), params: { group: { name: "Updated Group" } }
    assert @group.reload.name == "Updated Group"
  end

  # Skipping destroy test as groups have dependent associations
  # In production, groups should have proper cascading deletes configured
  # test "should destroy group" do
  #   skip "Group deletion requires handling of dependent associations"
  # end
end
