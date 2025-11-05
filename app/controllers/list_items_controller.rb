class ListItemsController < ApplicationController
  before_action :set_list
  before_action :set_list_item

  def toggle
    @list_item.update(ticked: params[:ticked])
    render json: { success: true, ticked: @list_item.ticked }
  end

  def update
    if @list_item.update(quantity: params[:quantity])
      render json: { success: true, quantity: @list_item.quantity }
    else
      render json: { success: false, errors: @list_item.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @list_item.destroy
    redirect_to root_path, notice: "Item removed from list"
  end

  private

  def set_list
    @list = List.find(params[:list_id])
  end

  def set_list_item
    @list_item = @list.list_items.find(params[:id])
  end

  def current_group
    Current.session&.selected_group || Group.find_by(name: "Test Group") || Group.first
  end
end
