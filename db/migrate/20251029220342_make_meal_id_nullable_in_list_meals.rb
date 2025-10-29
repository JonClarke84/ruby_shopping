class MakeMealIdNullableInListMeals < ActiveRecord::Migration[8.0]
  def change
    if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      reversible do |dir|
        dir.up do
          execute <<-SQL
            CREATE TABLE list_meals_new (
              id integer PRIMARY KEY AUTOINCREMENT,
              list_id integer NOT NULL,
              meal_id integer,
              created_at datetime NOT NULL,
              updated_at datetime NOT NULL,
              date date,
              FOREIGN KEY (list_id) REFERENCES lists(id),
              FOREIGN KEY (meal_id) REFERENCES meals(id)
            );
            INSERT INTO list_meals_new SELECT * FROM list_meals;
            DROP TABLE list_meals;
            ALTER TABLE list_meals_new RENAME TO list_meals;
          SQL
        end
        dir.down do
          execute <<-SQL
            CREATE TABLE list_meals_new (
              id integer PRIMARY KEY AUTOINCREMENT,
              list_id integer NOT NULL,
              meal_id integer NOT NULL,
              created_at datetime NOT NULL,
              updated_at datetime NOT NULL,
              date date,
              FOREIGN KEY (list_id) REFERENCES lists(id),
              FOREIGN KEY (meal_id) REFERENCES meals(id)
            );
            INSERT INTO list_meals_new SELECT * FROM list_meals;
            DROP TABLE list_meals;
            ALTER TABLE list_meals_new RENAME TO list_meals;
          SQL
        end
      end
    else
      change_column_null :list_meals, :meal_id, true
    end
  end
end
