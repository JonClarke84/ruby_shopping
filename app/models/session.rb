class Session < ApplicationRecord
  belongs_to :user
  belongs_to :selected_group, class_name: "Group", optional: true
end
