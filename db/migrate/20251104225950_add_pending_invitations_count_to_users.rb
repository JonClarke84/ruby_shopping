class AddPendingInvitationsCountToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :pending_invitations_count, :integer, default: 0, null: false

    # Backfill existing counts
    reversible do |dir|
      dir.up do
        User.find_each do |user|
          count = user.group_invitations.pending.where("created_at >= ?", 7.days.ago).count
          user.update_column(:pending_invitations_count, count)
        end
      end
    end
  end
end
