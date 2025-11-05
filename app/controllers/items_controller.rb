class ItemsController < ApplicationController
  before_action :set_list, only: [ :create ]
  before_action :set_item, only: [ :show, :edit, :update, :destroy ]

  def index
    @items = current_group.items
    @group = current_group
  end

  def show
  end

  def new
    @item = Item.new
  end

  def create
    # Find or create item with this name in the group
    @item = current_group.items.find_or_create_by(name: item_params[:name])

    # Check if this item is already on the list
    if @list.list_items.exists?(item_id: @item.id)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("new_item", partial: "items/form_with_error", locals: { list: @list, item: Item.new, error: "#{@item.name} is already on this list" }) }
        format.html { redirect_to root_path, alert: "#{@item.name} is already on this list" }
      end
    else
      @list_item = @list.list_items.create(item: @item, quantity: item_params[:quantity])
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to root_path }
      end
    end
  end

  def edit
  end

  def update
    params[:items].each do |item_str, quantity|
      puts item_str
    end
  end

  def destroy
    @item.destroy
    redirect_to items_path
  end

  private

  def set_list
    @list = current_group.lists.find(params[:list_id]) if current_group.lists.present?
  end

  def set_item
    @item = current_group.items.find(params[:id])
  end

  def item_params
    params.expect(item: [ :name, :quantity ])
  end

  def current_group
    Current.session&.selected_group || Group.find_by(name: "Test Group") || Group.first
  end
end
