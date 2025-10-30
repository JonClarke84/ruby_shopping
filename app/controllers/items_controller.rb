class ItemsController < ApplicationController
  before_action :set_list

  def index
    @items = Item.all
  end

  def show
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(name: item_params[:name], group_id: item_params[:group_id])
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
    @list = List.find(params[:list_id])
  end

  def item_params
    params.expect(item: [ :name, :quantity, :group_id ])
  end
end
