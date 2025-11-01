class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy invite send_invite ]
  skip_before_action :require_authentication if Rails.env.test?

  def index
    @groups = Current.user.groups
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
      Current.user.user_groups.create!(group: @group)
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
    # TODO: Implement mailer integration
    # For now, just redirect with a notice
    redirect_to groups_url, notice: "Invitation will be sent to #{email} (mailer not yet implemented)"
  end

  private

  def set_group
    @group = Current.user.groups.find(params.expect(:id))
  end

  def group_params
    params.expect(group: [ :name ])
  end
end
