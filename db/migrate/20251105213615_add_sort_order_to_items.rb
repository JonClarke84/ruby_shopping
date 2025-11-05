class AddSortOrderToItems < ActiveRecord::Migration[8.1]
  def up
    add_column :items, :sort_order, :decimal, precision: 15, scale: 5

    # Backfill sort_order from the most recent list for each group
    execute <<-SQL
      UPDATE items
      SET sort_order = (
        SELECT list_items.sort_order
        FROM list_items
        INNER JOIN lists ON lists.id = list_items.list_id
        WHERE list_items.item_id = items.id
          AND lists.group_id = items.group_id
        ORDER BY lists.created_at DESC, list_items.sort_order ASC
        LIMIT 1
      )
      WHERE EXISTS (
        SELECT 1 FROM list_items WHERE list_items.item_id = items.id
      )
    SQL

    # For items that have never been on a list, assign sequential sort_order per group
    Item.where(sort_order: nil).group_by(&:group_id).each do |group_id, items|
      max_order = Item.where(group_id: group_id).where.not(sort_order: nil).maximum(:sort_order) || 0.0
      items.each_with_index do |item, index|
        item.update_column(:sort_order, max_order + index + 1.0)
      end
    end
  end

  def down
    remove_column :items, :sort_order
  end
end
