class ListsController < ApplicationController
  before_action :set_list, only: %i[ show update destroy ]
  before_action :authorize_list, only: %i[ show update destroy ]
  skip_before_action :require_authentication if Rails.env.test?

  # GET / (Home tab - list of lists)
  def home
    @lists = current_group.lists.order(date: :desc)
  end

  # GET /list (List tab - view active list items)
  def show_current
    @list = current_list
    @item = Item.new
  end

  # GET /meals (Meals tab - view active list meals)
  def meals
    @list = current_list
  end

  # PATCH /select_list/:id (switch active list)
  def select
    list = current_group.lists.find(params[:id])
    Current.session&.update(selected_list: list)
    redirect_to current_list_tab_path
  end

  # Legacy index - redirect to home
  def index
    redirect_to root_path
  end

  # GET /lists/all
  def all
    @lists = current_group.lists.order(date: :desc)
  end

  # GET /lists/1
  def show
  end

  # GET /lists/new
  def new
    @list = List.new(date: Date.today)
  end

  # POST /lists
  def create
    @list = List.new(list_params)
    @list.group_id = current_group.id

    if @list.save
      # Auto-select the newly created list
      Current.session&.update(selected_list: @list)
      redirect_to current_list_tab_path
    end
  end

  # PATCH/PUT /lists/1
  def update
    respond_to do |format|
      if @list.update(list_params)
        format.html { redirect_to @list, notice: "List was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @list }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  def destroy
    @list.destroy!
    # Clear selection if the deleted list was selected
    if Current.session&.selected_list_id == @list.id
      Current.session&.update(selected_list_id: nil)
    end
    redirect_to root_path, notice: "List was successfully deleted.", status: :see_other
  end

  private

  def set_list
    @list = List.find(params.expect(:id))
  end

  def authorize_list
    unless @list && @list.group_id == current_group.id
      redirect_to root_path, alert: "You don't have access to that list"
    end
  end

  def list_params
    params.expect(list: [ :date ])
  end
end
