require "test_helper"

class ItemMailerTest < ActionMailer::TestCase
  test "in_stock" do
    item = items(:one)
    subscriber = subscribers(:one)

    mail = ItemMailer.with(item: item, subscriber: subscriber).in_stock

    assert_equal "In stock", mail.subject
    assert_equal [ subscriber.email ], mail.to
    assert_match item.name, mail.body.encoded
  end
end
