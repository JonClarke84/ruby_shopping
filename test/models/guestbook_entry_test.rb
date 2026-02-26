require "test_helper"

class GuestbookEntryTest < ActiveSupport::TestCase
  test "valid with name and message" do
    entry = GuestbookEntry.new(name: "Visitor", message: "Cool site!")
    assert entry.valid?
  end

  test "invalid without name" do
    entry = GuestbookEntry.new(message: "Cool site!")
    assert_not entry.valid?
  end

  test "invalid without message" do
    entry = GuestbookEntry.new(name: "Visitor")
    assert_not entry.valid?
  end

  test "orders by newest first" do
    old = GuestbookEntry.create!(name: "Old", message: "First", created_at: 1.day.ago)
    new_entry = GuestbookEntry.create!(name: "New", message: "Second")

    assert_equal new_entry, GuestbookEntry.recent.first
    assert_equal old, GuestbookEntry.recent.last
  end
end
