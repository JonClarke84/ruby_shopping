class AddDateToListMeals < ActiveRecord::Migration[8.0]
  def change
    add_column :list_meals, :date, :date
  end
end
