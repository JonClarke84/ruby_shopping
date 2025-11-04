require "test_helper"

class GroupInvitationTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @invitee = users(:two)
    @group = groups(:one)
  end

  test "should belong to user, group, and invited_by" do
    invitation = GroupInvitation.create!(
      user: @invitee,
      group: @group,
      invited_by: @user,
      status: :pending
    )
    assert_respond_to invitation, :user
    assert_respond_to invitation, :group
    assert_respond_to invitation, :invited_by
  end

  test "should have status enum" do
    invitation = GroupInvitation.new(user: @invitee, group: @group, invited_by: @user)
    invitation.status = :pending
    assert invitation.pending?

    invitation.status = :accepted
    assert invitation.accepted?

    invitation.status = :declined
    assert invitation.declined?

    invitation.status = :expired
    assert invitation.expired?
  end

  test "should not allow duplicate pending invitations for same user and group" do
    # Create first invitation
    invitation1 = GroupInvitation.create!(
      user: @invitee,
      group: @group,
      invited_by: @user,
      status: :pending
    )

    # Try to create duplicate
    invitation2 = GroupInvitation.new(
      user: @invitee,
      group: @group,
      invited_by: @user,
      status: :pending
    )

    assert_not invitation2.valid?
    assert_includes invitation2.errors[:user_id], "already has a pending invitation to this group"
  end

  test "should allow multiple invitations for same user and group if not pending" do
    # Create accepted invitation
    invitation1 = GroupInvitation.create!(
      user: @invitee,
      group: @group,
      invited_by: @user,
      status: :accepted
    )

    # Create new pending invitation
    invitation2 = GroupInvitation.new(
      user: @invitee,
      group: @group,
      invited_by: @user,
      status: :pending
    )

    assert invitation2.valid?
  end

  test "pending_and_not_expired scope should return only recent pending invitations" do
    recent_invitation = GroupInvitation.create!(
      user: @invitee,
      group: @group,
      invited_by: @user,
      status: :pending,
      created_at: 2.days.ago
    )

    old_invitation = GroupInvitation.create!(
      user: @invitee,
      group: groups(:two),
      invited_by: @user,
      status: :pending,
      created_at: 10.days.ago
    )

    accepted_invitation = GroupInvitation.create!(
      user: @user,
      group: groups(:two),
      invited_by: @invitee,
      status: :accepted,
      created_at: 5.days.ago
    )

    invitations = GroupInvitation.pending_and_not_expired
    assert_includes invitations, recent_invitation
    assert_not_includes invitations, old_invitation
    assert_not_includes invitations, accepted_invitation
  end

  test "expired_pending scope should return old pending invitations" do
    recent_invitation = GroupInvitation.create!(
      user: @invitee,
      group: @group,
      invited_by: @user,
      status: :pending,
      created_at: 2.days.ago
    )

    old_invitation = GroupInvitation.create!(
      user: @invitee,
      group: groups(:two),
      invited_by: @user,
      status: :pending,
      created_at: 10.days.ago
    )

    invitations = GroupInvitation.expired_pending
    assert_includes invitations, old_invitation
    assert_not_includes invitations, recent_invitation
  end

  test "expire_old_invitations! should mark old pending invitations as expired" do
    old_invitation = GroupInvitation.create!(
      user: @invitee,
      group: @group,
      invited_by: @user,
      status: :pending,
      created_at: 10.days.ago
    )
    assert old_invitation.pending?

    GroupInvitation.expire_old_invitations!

    old_invitation.reload
    assert old_invitation.expired?
  end

  test "accept! should mark invitation as accepted and create UserGroup" do
    invitation = GroupInvitation.create!(
      user: @invitee,
      group: @group,
      invited_by: @user,
      status: :pending
    )
    user = invitation.user
    group = invitation.group

    assert_difference "UserGroup.count", 1 do
      invitation.accept!
    end

    assert invitation.accepted?
    assert group.users.include?(user)
  end

  test "decline! should mark invitation as declined" do
    invitation = GroupInvitation.create!(
      user: @invitee,
      group: @group,
      invited_by: @user,
      status: :pending
    )
    invitation.decline!

    assert invitation.declined?
  end
end
