class AddSortOrderToListItems < ActiveRecord::Migration[8.0]
  def change
    add_column :list_items, :sort_order, :decimal
  end
end
