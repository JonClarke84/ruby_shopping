class Item < ApplicationRecord
  include Notifications

  belongs_to :group

  has_many :list_items
  has_many :lists, through: :list_items

  validates :name, presence: true, uniqueness: { scope: :group_id, case_sensitive: false }
  validates :group_id, presence: true
end
