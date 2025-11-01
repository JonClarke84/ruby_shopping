class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  def switch_group
    user = Current.user || User.first
    group = user.groups.find(params[:group_id])

    # Update user's saved preference
    if user.user_group_selection
      user.user_group_selection.update(group: group)
    else
      user.create_user_group_selection(group: group)
    end

    # Update current session if it exists
    Current.session&.update(selected_group: group)

    redirect_to root_path, notice: "Switched to #{group.name}"
  end
end
