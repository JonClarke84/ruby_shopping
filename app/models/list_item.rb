class ListItem < ApplicationRecord
  belongs_to :list
  belongs_to :item

  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
