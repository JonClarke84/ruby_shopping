class AddIsDefaultToUserGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :user_groups, :is_default, :boolean, default: false, null: false
    add_index :user_groups, [ :user_id, :is_default ], unique: true, where: "is_default = true", name: "index_user_groups_on_user_id_and_is_default_true"
  end
end
