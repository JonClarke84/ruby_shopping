class GroupController < ApplicationController
  has_many :user_groups
  has_many :users, through: :user_groups

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def delete
  end

  def destroy
  end

  def index
  end

  def show
  end
end
