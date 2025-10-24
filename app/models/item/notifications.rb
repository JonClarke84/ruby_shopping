module Item::Notifications
  extend ActiveSupport::Concern

  included do
    has_many :subscribers, dependent: :destroy
  end

  def notify_subscribers
    subscribers.each do |subscriber|
      ItemMailer.with(product: self, subscriber: subscriber).in_stock.deliver_later
    end
  end
end
