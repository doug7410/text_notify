class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_up_customers_and_group, only: [:show, :update]

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
  end

  def update
    if @group.update(params.require(:group).permit(:name))
      flash[:success] = "The customer group has been updated."
      redirect_to @group
    else
      render :show
    end
  end

  def add_customer
    @group = Group.find(params[:id])
    customer = Customer.find(params[:customer_id])
    @group.customers << customer
    @customers_not_in_group = Customer.all - @group.customers
    @group_customers = @group.customers.decorate
    redirect_to group_path(@group)
  end

  def remove_customer
    @group = Group.find(params[:id])
    customer = Customer.find(params[:customer_id])
    customer_group = @group.customer_groups.where("customer_id = ?", customer.id)
    CustomerGroup.destroy(customer_group)
    @customers_not_in_group = Customer.all - @group.customers
    @group_customers = @group.customers.decorate
    redirect_to group_path(@group)
  end

private 
  
  def set_up_customers_and_group
    @group = Group.find(params[:id])
    @group_customers = @group.customers.decorate
    @customers_not_in_group = Customer.all - @group.customers
  end 
end