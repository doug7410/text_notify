class GroupsController < ApplicationController
  before_filter :authenticate_business_owner!
  before_filter :set_up_customers_and_group, only: [:show, :update]

  def index
    @group = Group.new
    @groups = Group.where("business_owner_id = ?", current_business_owner.id)
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      flash[:success] = "The \"#{@group.name}\" group has been created."
      redirect_to groups_path
    else
      @groups = Group.where("business_owner_id = ?", current_business_owner.id)
      render :index
    end
  end

  def show
    @customer = Customer.new
  end

  def update
    respond_to do |format|
      format.html do
        @customer = Customer.new(customer_params)
        @customer.phone_number = Customer.format_phone_number(@customer.phone_number)
        if @customer.save
          Membership.create(customer: @customer, group: @group, current_business_owner: current_business_owner)
          redirect_to @group
        else
          render :show
        end
      end

      format.js do
        if @group.update(params.require(:group).permit(:name))
          flash[:success] = "Group name has been updated."
        end
          
        render :show
      end
    end
  end

  def destroy
    group = Group.find(params[:id])
    if group.business_owner == current_business_owner
      group.destroy
      flash[:error] = "#{group.name} has been deleted"
      redirect_to groups_path
    else
      flash[:error] = "You can't delete that group"
      render :index
    end
  end

private 
  def group_params
    params.require(:group).permit(:name).merge(business_owner_id: current_business_owner.id)
  end

  def customer_params
    params.require(:group).permit(:group, {:customer => [:first_name, :last_name, :phone_number]})[:customer].merge(business_owner_id: current_business_owner.id)
  end

  def set_up_customers_and_group
    @group = Group.find(params[:id])
    @members = Membership.where(group: @group)
    @customers_not_in_group = current_business_owner.customers.all - @group.customers
  end 
end