class ChangeListItemsSortOrderPrecision < ActiveRecord::Migration[8.1]
  def up
    change_column :list_items, :sort_order, :decimal, precision: 15, scale: 5
  end

  def down
    change_column :list_items, :sort_order, :decimal
  end
end
