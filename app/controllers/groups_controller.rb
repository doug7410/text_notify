class GroupsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @group = Group.new
    @groups = Group.where("user_id = ?", current_user.id)
  end

  def create
    @group = Group.new(params.require(:group).permit(:name).merge(user_id: current_user.id))
    if @group.save
      redirect_to groups_path
    else
      @groups = Group.where("user_id = ?", current_user.id)
      render :index
    end
  end

  def show
    @group = Group.find(params[:id])
    @group_customers = @group.customers.decorate
    @customers_not_in_group = Customer.all - @group.customers
    @customers_not_in_group
  end
end