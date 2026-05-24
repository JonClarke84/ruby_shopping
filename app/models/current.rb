class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true

  def group
    session&.selected_group || user&.user_group_selection&.group || user&.groups&.first
  end
end
