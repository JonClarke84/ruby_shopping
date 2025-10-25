class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  # def index
  # end

  # def show
  # end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      session.delete(:return_to_after_authenticating)
      redirect_to root_path, notice: "Welcome!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @user = User.new
  end

  def edit
  end

  def update
  end

  def delete
  end

  def destroy
  end

  private
    def user_params
      params.expect(user: [ :first_name, :last_name, :email_address, :password, :password_confirmation ])
    end
end
