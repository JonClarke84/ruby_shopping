class CreateLists < ActiveRecord::Migration[8.0]
  def change
    create_table :lists do |t|
      t.date :date

      t.timestamps
    end
  end
end
