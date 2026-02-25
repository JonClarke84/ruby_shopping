class MealsController < ApplicationController
  before_action :set_list
  skip_before_action :require_authentication if Rails.env.test?

  def update
    params[:meals].each do |date_str, meal_name|
      date = Date.parse(date_str)

      if meal_name.blank?
        # Delete the ListMeal for this date if meal name is blank
        @list.list_meals.find_by(date: date)&.destroy
      else
        # Find or create the meal, then find or create the ListMeal
        meal = Meal.find_or_create_by(name: meal_name, group_id: @list.group_id)
        ListMeal.find_or_create_by(list: @list, date: date) do |lm|
          lm.meal = meal
        end
      end
    end

    redirect_to meals_tab_path, notice: "Meals updated successfully"
  end

  def destroy
  end

  private

  def set_list
    @list = current_group.lists.find(params[:list_id])
  end

end
