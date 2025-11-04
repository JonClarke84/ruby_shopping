require "test_helper"

class GroupInvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = users(:one)
    @other_user = users(:two)
    Current.session = sessions(:one)  # This session belongs to users(:one)
  end

  test "should get index" do
    get group_invitations_url
    assert_response :success
  end

  test "index should only show pending and not expired invitations" do
    # Create a recent pending invitation for current user
    recent_invitation = GroupInvitation.create!(
      user: @current_user,
      group: groups(:two),
      invited_by: @other_user,
      status: :pending,
      created_at: 2.days.ago
    )

    # Create an old pending invitation (should be filtered out)
    old_invitation = GroupInvitation.create!(
      user: @current_user,
      group: groups(:one),
      invited_by: @other_user,
      status: :pending,
      created_at: 10.days.ago
    )

    get group_invitations_url
    assert_response :success

    # Should include recent invitation
    assert_select "h3", text: recent_invitation.group.name

    # Should not include old invitation (expired)
    assert_select "h3", { text: old_invitation.group.name, count: 0 }
  end

  test "should accept invitation and join group" do
    group = groups(:two)
    invitation = GroupInvitation.create!(
      user: @current_user,
      group: group,
      invited_by: @other_user,
      status: :pending
    )

    assert_not group.users.include?(@current_user), "User should not be in group before accepting"

    assert_difference "UserGroup.count", 1 do
      post accept_group_invitation_url(invitation)
    end

    assert_redirected_to groups_path
    assert_equal "You have joined #{group.name}", flash[:notice]

    invitation.reload
    assert invitation.accepted?
    assert group.users.include?(@current_user), "User should be in group after accepting"
  end

  test "should decline invitation" do
    group = groups(:two)
    invitation = GroupInvitation.create!(
      user: @current_user,
      group: group,
      invited_by: @other_user,
      status: :pending
    )

    assert_no_difference "UserGroup.count" do
      post decline_group_invitation_url(invitation)
    end

    assert_redirected_to group_invitations_path
    assert_equal "Invitation declined", flash[:notice]

    invitation.reload
    assert invitation.declined?
    assert_not group.users.include?(@current_user), "User should not be in group after declining"
  end

  test "should only allow user to accept their own invitations" do
    # Create an invitation for other user
    invitation_for_other_user = GroupInvitation.create!(
      user: @other_user,
      group: groups(:two),
      invited_by: @current_user,
      status: :pending
    )

    # Current user (users(:one)) tries to accept invitation meant for users(:two)
    # This should raise RecordNotFound because the invitation belongs to other_user
    post accept_group_invitation_url(invitation_for_other_user)

    # If we reach here without exception, the test should fail
    # But Rails handles RecordNotFound and returns 404
    assert_response :not_found
  end
end
