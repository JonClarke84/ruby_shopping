class CreateSiteCounters < ActiveRecord::Migration[8.1]
  def change
    create_table :site_counters do |t|
      t.string :name
      t.integer :value, default: 0, null: false

      t.timestamps
    end
    add_index :site_counters, :name, unique: true
  end
end
