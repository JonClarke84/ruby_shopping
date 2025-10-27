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

  test "should destroy group" do
    # Create a new group for deletion to avoid foreign key constraints
    group_to_delete = Group.create!(name: "Deletable Group")

    assert_difference("Group.count", -1) do
      delete group_url(group_to_delete)
    end
  end
end
