class ListsController < ApplicationController
  before_action :set_list, only: %i[ show update destroy ]
  before_action :authorize_list, only: %i[ show update destroy ]
  skip_before_action :require_authentication if Rails.env.test?

  # GET /lists or /lists.json
  def index
    @list = current_group.lists.last
    @item = Item.new
  end

  # GET /lists/1 or /lists/1.json
  def show
  end

  # GET /lists/new
  def new
    @list = List.new(date: Date.today)
  end

  # POST /lists or /lists.json
  def create
    @list = List.new(list_params)
    @list.group_id = current_group.id

    redirect_to root_path if @list.save
  end

  # PATCH/PUT /lists/1 or /lists/1.json
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

  # DELETE /lists/1 or /lists/1.json
  def destroy
    @list.destroy!

    respond_to do |format|
      format.html { redirect_to lists_path, notice: "List was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      @list = List.find(params.expect(:id))
    end

    def authorize_list
      unless @list && @list.group_id == current_group.id
        redirect_to root_path, alert: "You don't have access to that list"
      end
    end

    # Only allow a list of trusted parameters through.
    def list_params
      params.expect(list: [ :date ])
    end

    def current_group
      Current.session&.selected_group || Group.find_by(name: "Test Group") || Group.first
    end
end
