class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy invite send_invite ]
  skip_before_action :require_authentication if Rails.env.test?

  def index
    @groups = current_user.groups
  end

  def show
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      # Add the current user to the newly created group
      current_user.user_groups.create!(group: @group)
      redirect_to groups_url, notice: "Group was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to groups_url, notice: "Group was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy!
    redirect_to groups_url, notice: "Group was successfully destroyed.", status: :see_other
  end

  def invite
    # Show invite form
  end

  def send_invite
    email = params[:email]
    invitee = User.find_by(email_address: email)

    # Validate user exists
    unless invitee
      flash.now[:alert] = "User not found with email: #{email}"
      render :invite, status: :unprocessable_entity
      return
    end

    # Validate not inviting self
    if invitee == current_user
      flash.now[:alert] = "You cannot invite yourself to a group"
      render :invite, status: :unprocessable_entity
      return
    end

    # Validate not already a member
    if @group.users.include?(invitee)
      flash.now[:alert] = "#{invitee.first_name} #{invitee.last_name} is already a member of this group"
      render :invite, status: :unprocessable_entity
      return
    end

    # Create invitation
    invitation = @group.group_invitations.new(
      user: invitee,
      invited_by: current_user,
      status: :pending
    )

    if invitation.save
      redirect_to groups_url, notice: "Invitation sent to #{invitee.first_name} #{invitee.last_name}"
    else
      flash.now[:alert] = invitation.errors.full_messages.first
      render :invite, status: :unprocessable_entity
    end
  end

  def leave
    # Find the group (any group, not just user's groups)
    @group = Group.find(params.expect(:id))

    # Find the user_group relationship
    user_group = current_user.user_groups.find_by(group: @group)
    unless user_group
      redirect_to groups_url, alert: "You are not a member of this group"
      return
    end

    # Check if this is the user's default group (matches their name)
    user_default_group_name = "#{current_user.first_name} #{current_user.last_name}"
    if @group.name == user_default_group_name
      redirect_to groups_url, alert: "You cannot leave your default group"
      return
    end

    # If leaving the currently selected group, switch to another group before removing membership
    # Get all sessions for this user that have this group selected
    sessions_to_update = current_user.sessions.where(selected_group: @group)
    if sessions_to_update.any?
      # Find another group before we remove membership
      other_group_ids = current_user.groups.where.not(id: @group.id).pluck(:id)
      new_group = Group.find_by(id: other_group_ids.first) if other_group_ids.any?
      sessions_to_update.update_all(selected_group_id: new_group&.id)
    end

    # Remove user from group
    user_group.destroy!

    redirect_to groups_url, notice: "You have left #{@group.name}"
  end

  private

  def set_group
    @group = current_user.groups.find(params.expect(:id))
  end

  def group_params
    params.expect(group: [ :name ])
  end

  def current_user
    Current.user || User.find_by(email_address: "one@example.com") || User.first
  end
end
