class GroupInvitation < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :invited_by, class_name: "User"

  enum :status, { pending: 0, accepted: 1, declined: 2, expired: 3 }

  validates :user_id, uniqueness: { scope: [ :group_id, :status ],
                                    conditions: -> { where(status: :pending) },
                                    message: "already has a pending invitation to this group" }

  scope :pending_and_not_expired, -> { pending.where("created_at >= ?", 7.days.ago) }
  scope :expired_pending, -> { pending.where("created_at < ?", 7.days.ago) }

  def self.expire_old_invitations!
    expired_pending.update_all(status: :expired)
  end

  def accept!
    transaction do
      update!(status: :accepted)
      UserGroup.create!(user: user, group: group)
    end
  end

  def decline!
    update!(status: :declined)
  end
end
