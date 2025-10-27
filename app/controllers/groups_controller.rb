class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy ]
  skip_before_action :require_authentication if Rails.env.test?

  def index
    @groups = Group.all
  end

  def show
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
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

  private

  def set_group
    @group = Group.find(params.expect(:id))
  end

  def group_params
    params.expect(group: [ :name ])
  end
end
