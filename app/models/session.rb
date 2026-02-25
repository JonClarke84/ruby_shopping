class Session < ApplicationRecord
  belongs_to :user
  belongs_to :selected_group, class_name: "Group", optional: true
  belongs_to :selected_list, class_name: "List", optional: true
end
