class AddUniqueIndexToGroupInvitations < ActiveRecord::Migration[8.1]
  def change
    add_index :group_invitations, [ :user_id, :group_id ],
              unique: true,
              where: "status = 0",
              name: "index_group_invitations_on_user_and_group_pending"
  end
end
