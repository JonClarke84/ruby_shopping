class GroupInvitation < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :invited_by, class_name: "User"

  enum :status, { pending: 0, accepted: 1, declined: 2, expired: 3 }

  # Maintain counter cache for pending invitations
  after_create :increment_counter, if: :pending?
  after_update :update_counter, if: :saved_change_to_status?
  after_destroy :decrement_counter, if: -> { status_before_destroy == "pending" }

  attr_accessor :status_before_destroy

  before_destroy :store_status

  def store_status
    self.status_before_destroy = status
  end

  validates :user_id, uniqueness: { scope: [ :group_id, :status ],
                                    conditions: -> { where(status: :pending) },
                                    message: "already has a pending invitation to this group" }

  scope :pending_and_not_expired, -> { pending.where("created_at >= ?", 7.days.ago) }
  scope :expired_pending, -> { pending.where("created_at < ?", 7.days.ago) }

  def self.expire_old_invitations!
    expired_pending.find_each do |invitation|
      invitation.update!(status: :expired)
    end
  end

  def accept!
    transaction do
      update!(status: :accepted)
      UserGroup.find_or_create_by!(user: user, group: group)
    end
  end

  def decline!
    update!(status: :declined)
  end

  private

  def increment_counter
    user.increment!(:pending_invitations_count)
  end

  def decrement_counter
    user.decrement!(:pending_invitations_count) if user.pending_invitations_count > 0
  end

  def update_counter
    if status_previously_was == "pending" && !pending?
      decrement_counter
    elsif pending? && status_previously_was != "pending"
      increment_counter
    end
  end
end
