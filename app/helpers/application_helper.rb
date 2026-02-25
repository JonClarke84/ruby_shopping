module ApplicationHelper
  def active_tab
    case controller_name
    when "lists"
      case action_name
      when "home" then :home
      when "show_current" then :list
      when "meals" then :meals
      else :home
      end
    when "items"
      :home
    when "groups", "sessions", "group_invitations", "users", "passwords"
      :account
    else
      :home
    end
  end

  def page_title
    case controller_name
    when "lists"
      case action_name
      when "home" then "Home"
      when "show_current" then "Shopping List"
      when "meals" then "Meals"
      when "all" then "All Lists"
      when "new" then "New List"
      when "show" then "List Details"
      else "Lists"
      end
    when "items"
      case action_name
      when "index" then "Items"
      when "new" then "New Item"
      when "edit" then "Edit Item"
      else "Items"
      end
    when "groups"
      case action_name
      when "index" then "Groups"
      when "new" then "New Group"
      when "edit" then "Edit Group"
      else "Groups"
      end
    when "group_invitations"
      "Invitations"
    when "sessions"
      "Account"
    else
      "Ruby Shopping"
    end
  end
end
