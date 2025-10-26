class AddGroupToLists < ActiveRecord::Migration[8.0]
  def change
    add_reference :lists, :group, null: true, foreign_key: true
  end
end
