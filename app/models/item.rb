class Item < ApplicationRecord
  include Notifications

  belongs_to :group

  has_many :list_items
  has_many :lists, through: :list_items

  validates :name, presence: true
  validates :group_id, presence: true
end
