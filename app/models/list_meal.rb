class ListMeal < ApplicationRecord
  belongs_to :list
  belongs_to :meal
end
