class List < ApplicationRecord
  belongs_to :group

  has_many :list_items, dependent: :destroy
  has_many :items, through: :list_items
  has_many :list_meals, dependent: :destroy
  has_many :meals, through: :list_meals

  before_validation :set_default_end_date

  validates :end_date, comparison: { greater_than_or_equal_to: :date }, if: -> { date.present? && end_date.present? }

  def meal_for_date(date)
    list_meals.find_by(date: date)&.meal
  end

  def date_range
    date..end_date
  end

  def duration_days
    (end_date - date).to_i + 1
  end

  private

  def set_default_end_date
    self.end_date ||= date + 6.days if date.present?
  end
end
