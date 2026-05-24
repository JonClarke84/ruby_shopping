require "test_helper"

class CurrentGroupTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @group_one = groups(:one)
    @group_two = groups(:two)
    @user.groups << @group_two unless @user.groups.include?(@group_two)
  end

  test "Current.group returns session selected group" do
    session = sessions(:one)
    session.update!(selected_group: @group_two)
    Current.session = session

    assert_equal @group_two, Current.group
  end

  test "Current.group falls back to user selection if session has none" do
    session = sessions(:one)
    session.update!(selected_group: nil)
    Current.session = session

    UserGroupSelection.find_or_create_by!(user: @user) do |ugs|
      ugs.group = @group_one
    end

    assert_equal @group_one, Current.group
  end

  test "Current.group falls back to user default group if no selection exists" do
    session = sessions(:one)
    session.update!(selected_group: nil)
    Current.session = session
    @user.user_group_selection&.destroy

    assert_includes @user.groups, Current.group
  end
end
