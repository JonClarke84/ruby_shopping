class Subscriber < ApplicationRecord
  belongs_to :item
  generates_token_for :unsubscribe
end
