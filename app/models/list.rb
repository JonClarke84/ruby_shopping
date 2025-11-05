class List < ApplicationRecord
  belongs_to :group

  has_many :list_items, dependent: :destroy
  has_many :items, through: :list_items
  has_many :list_meals, dependent: :destroy
  has_many :meals, through: :list_meals

  def meal_for_date(date)
    list_meals.find_by(date: date)&.meal
  end
end
