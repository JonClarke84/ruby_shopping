class AddGroupToItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :items, :group, null: true, foreign_key: true
  end
end
