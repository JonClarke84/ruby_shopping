class RemoveSortOrderFromListItems < ActiveRecord::Migration[8.1]
  def up
    remove_column :list_items, :sort_order
  end

  def down
    add_column :list_items, :sort_order, :decimal, precision: 15, scale: 5
  end
end
