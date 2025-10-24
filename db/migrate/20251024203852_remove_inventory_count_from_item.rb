class RemoveInventoryCountFromItem < ActiveRecord::Migration[8.0]
  def change
    remove_column :items, :inventory_count, :integer
  end
end
