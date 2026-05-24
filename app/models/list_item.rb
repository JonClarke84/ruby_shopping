class ListItem < ApplicationRecord
  belongs_to :list
  belongs_to :item

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  after_create_commit  -> { broadcast_prepend_to [ list, "list_items" ], target: "list-items", partial: "list_items/list_item", locals: { list_item: self } }
  after_update_commit  -> { broadcast_replace_to [ list, "list_items" ], target: self, partial: "list_items/list_item", locals: { list_item: self } }
  after_destroy_commit -> { broadcast_remove_to [ list, "list_items" ], target: self }
end
