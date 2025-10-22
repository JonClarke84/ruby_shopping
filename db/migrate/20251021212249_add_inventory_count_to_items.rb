class AddInventoryCountToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :inventory_count, :integer
  end
end
