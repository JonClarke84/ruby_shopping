class GuestbookEntry < ApplicationRecord
  validates :name, presence: true
  validates :message, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
