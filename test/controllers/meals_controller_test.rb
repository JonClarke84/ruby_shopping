require "test_helper"

class MealsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @list = lists(:one)
    @meal = meals(:one)
  end

  test "should update meals" do
    assert_difference("ListMeal.count") do
      patch list_meals_url(@list), params: { meals: { "2025-10-27" => "Test Meal" } }
    end

    assert_redirected_to meals_tab_path
  end

  test "should update existing meals" do
    date = "2025-10-27"
    patch list_meals_url(@list), params: { meals: { date => "Initial Meal" } }
    
    assert_no_difference("ListMeal.count") do
      patch list_meals_url(@list), params: { meals: { date => "Updated Meal" } }
    end

    assert_equal "Updated Meal", @list.list_meals.find_by(date: date).meal.name
    assert_redirected_to meals_tab_path
  end
end
