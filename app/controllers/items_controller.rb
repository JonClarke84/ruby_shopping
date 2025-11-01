class ItemsController < ApplicationController
  before_action :set_list

  def index
    @items = Current.session.selected_group.items
  end

  def show
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(name: item_params[:name], group_id: Current.session.selected_group_id)
    if @item.save
      @list.list_items.create(item: @item, quantity: item_params[:quantity])
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
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
    @list = Current.session.selected_group.lists.find(params[:list_id])
  end

  def item_params
    params.expect(item: [ :name, :quantity ])
  end
end
