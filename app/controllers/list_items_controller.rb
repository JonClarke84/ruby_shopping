class ListItemsController < ApplicationController
  before_action :set_list
  before_action :authorize_list
  before_action :set_list_item
  skip_before_action :require_authentication if Rails.env.test?

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
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to current_list_tab_path, notice: "Item removed from list" }
    end
  end

  def reorder
    previous_list_item_id = params[:previous_id]
    next_list_item_id = params[:next_id]

    # Get the actual Item objects from the list_items
    previous_item = if previous_list_item_id.present?
      @list.list_items.find(previous_list_item_id).item
    end

    next_item = if next_list_item_id.present?
      @list.list_items.find(next_list_item_id).item
    end

    # Calculate new sort_order for the item
    new_sort_order = Item.calculate_new_sort_order(previous_item, next_item)
    @list_item.item.update(sort_order: new_sort_order)

    render json: { success: true, sort_order: @list_item.item.sort_order }
  end

  private

  def set_list
    @list = List.find(params[:list_id])
  end

  def authorize_list
    unless @list && @list.group_id == current_group.id
      redirect_to current_list_tab_path, alert: "You don't have access to that list"
    end
  end

  def set_list_item
    @list_item = @list.list_items.find(params[:id])
  end

end
