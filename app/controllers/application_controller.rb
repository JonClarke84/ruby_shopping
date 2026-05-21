class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def current_user
    Current.user
  end

  def current_list
    selected = Current.session&.selected_list
    # Fall back to most recent list if selection is nil or belongs to a different group
    if selected && current_group && selected.group_id == current_group.id
      selected
    else
      current_group&.lists&.last
    end
  end

  def current_group
    Current.session&.selected_group
  end

  helper_method :current_list
end
