class AddSelectedGroupIdToSessions < ActiveRecord::Migration[8.0]
  def change
    add_reference :sessions, :selected_group, foreign_key: { to_table: :groups }, null: true
  end
end
