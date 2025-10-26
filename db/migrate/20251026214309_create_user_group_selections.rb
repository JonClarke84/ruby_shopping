class CreateUserGroupSelections < ActiveRecord::Migration[8.0]
  def change
    create_table :user_group_selections do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
