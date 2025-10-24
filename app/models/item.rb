class Item < ApplicationRecord
  include Notifications

  has_many :list_items
  has_many :lists, through: :list_items

  has_one_attached :featured_image
  has_rich_text :description

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
