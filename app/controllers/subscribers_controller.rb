class SubscribersController < ApplicationController
  allow_unauthenticated_access
  before_action :set_item

  def create
    @item.subscribers.where(subscriber_params).first_or_create
    redirect_to @item, notice: "You are now subscribed."
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def subscriber_params
    params.expect(subscriber: [ :email ])
  end
end
