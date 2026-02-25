class AddEndDateToLists < ActiveRecord::Migration[8.1]
  def up
    add_column :lists, :end_date, :date
    # Backfill existing lists to end 6 days after start (7-day range)
    execute "UPDATE lists SET end_date = date(date, '+6 days') WHERE end_date IS NULL"
  end

  def down
    remove_column :lists, :end_date
  end
end
