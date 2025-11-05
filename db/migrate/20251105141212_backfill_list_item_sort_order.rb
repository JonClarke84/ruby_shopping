class BackfillListItemSortOrder < ActiveRecord::Migration[8.1]
  def up
    # Backfill sort_order for existing list items
    # Group by list_id and assign sequential sort_order values
    List.find_each do |list|
      list.list_items.where(sort_order: nil).order(:id).each_with_index do |list_item, index|
        list_item.update_column(:sort_order, index + 1.0)
      end
    end
  end

  def down
    # No need to reverse this operation
  end
end
