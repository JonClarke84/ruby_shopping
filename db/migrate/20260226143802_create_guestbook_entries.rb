class CreateGuestbookEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :guestbook_entries do |t|
      t.string :name
      t.text :message

      t.timestamps
    end
  end
end
