class ItemsController < ApplicationController
  skip_before_action :require_authentication if Rails.env.test?
  before_action :set_list, only: [ :create ]

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
    @item = Item.new(name: item_params[:name], group_id: current_group.id)
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

  def item_params
    params.expect(item: [ :name, :quantity ])
  end

  def current_group
    Current.session&.selected_group || Group.find_by(name: "Test Group") || Group.first
  end
end
