class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :lists
  has_many :items
  has_many :meals
  has_many :group_invitations, dependent: :destroy
  has_many :sessions, foreign_key: :selected_group_id, dependent: :nullify
end
