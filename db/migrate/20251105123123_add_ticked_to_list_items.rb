class AddTickedToListItems < ActiveRecord::Migration[8.1]
  def change
    add_column :list_items, :ticked, :boolean, default: false, null: false
  end
end
