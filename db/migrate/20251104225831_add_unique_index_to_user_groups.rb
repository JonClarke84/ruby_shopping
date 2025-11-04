class AddUniqueIndexToUserGroups < ActiveRecord::Migration[8.1]
  def change
    add_index :user_groups, [ :user_id, :group_id ], unique: true
  end
end
