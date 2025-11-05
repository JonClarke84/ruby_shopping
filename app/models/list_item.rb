class ListItem < ApplicationRecord
  belongs_to :list
  belongs_to :item

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  after_create :set_initial_sort_order

  # Calculate new sort_order using fractional/decimal ordering algorithm
  # previous_item: The list item before the target position (nil if moving to first)
  # next_item: The list item after the target position (nil if moving to last)
  def self.calculate_new_sort_order(previous_item, next_item)
    if previous_item.nil? && next_item.nil?
      # Only item in list
      1.0
    elsif previous_item.nil?
      # Moving to first position
      next_item.sort_order - 1.0
    elsif next_item.nil?
      # Moving to last position
      previous_item.sort_order + 1.0
    else
      # Moving between two items - calculate midpoint
      (previous_item.sort_order + next_item.sort_order) / 2.0
    end
  end

  private

  def set_initial_sort_order
    return if sort_order.present?

    # Set sort_order to be after all existing items in the list
    max_order = list.list_items.where.not(id: id).maximum(:sort_order) || 0.0
    update_column(:sort_order, max_order + 1.0)
  end
end
