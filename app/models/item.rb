class Item < ApplicationRecord
  include Notifications

  belongs_to :group

  has_many :list_items
  has_many :lists, through: :list_items

  validates :name, presence: true, uniqueness: { scope: :group_id, case_sensitive: false }
  validates :group_id, presence: true

  after_create :set_initial_sort_order

  # Calculate new sort_order using fractional/decimal ordering algorithm
  # previous_item: The item before the target position (nil if moving to first)
  # next_item: The item after the target position (nil if moving to last)
  def self.calculate_new_sort_order(previous_item, next_item)
    if previous_item.nil? && next_item.nil?
      # Only item in group
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

    # Set sort_order to be after all existing items in the group
    max_order = group.items.where.not(id: id).maximum(:sort_order) || 0.0
    update_column(:sort_order, max_order + 1.0)
  end
end
