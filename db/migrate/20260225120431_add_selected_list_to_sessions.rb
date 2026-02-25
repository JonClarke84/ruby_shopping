class AddSelectedListToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :selected_list_id, :integer
  end
end
