class CreateListMeals < ActiveRecord::Migration[8.0]
  def change
    create_table :list_meals do |t|
      t.references :list, null: false, foreign_key: true
      t.references :meal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
