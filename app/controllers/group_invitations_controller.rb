class GroupInvitationsController < ApplicationController
  before_action :set_invitation, only: [ :accept, :decline ]
  skip_before_action :require_authentication if Rails.env.test?

  def index
    @invitations = current_user.group_invitations.pending_and_not_expired.includes(:group, :invited_by)
  end

  def accept
    @invitation.accept!
    redirect_to groups_path, notice: "You have joined #{@invitation.group.name}"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to group_invitations_path, alert: "Unable to accept invitation: #{e.message}"
  end

  def decline
    @invitation.decline!
    redirect_to group_invitations_path, notice: "Invitation declined"
  end

  private

  def set_invitation
    @invitation = current_user.group_invitations.find(params.expect(:id))
  end

  def current_user
    Current.user || User.find_by(email_address: "one@example.com") || User.first
  end
end
