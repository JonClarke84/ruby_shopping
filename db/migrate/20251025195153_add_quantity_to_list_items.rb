class AddQuantityToListItems < ActiveRecord::Migration[8.0]
  def change
    add_column :list_items, :quantity, :integer
  end
end
