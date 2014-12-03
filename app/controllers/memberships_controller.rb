class MembershipsController < ApplicationController
  before_filter :authenticate_business_owner!
   

  def create 
    group = Group.find_by_id(params[:group])
    customer = Customer.find_by_id(params[:customer])
    membership = Membership.new(group: group, customer: customer, current_business_owner: current_business_owner)
    if membership.save 
      redirect_to group 
    else
      flash[:error] = "you can't do that"
      redirect_to group_path(group)
    end
  end
 
  def destroy
    membership = Membership.find(params[:id])
    group = Group.find(membership.group)

    if group.business_owner == current_business_owner
      membership.destroy
    else
      flash[:error] = "you can't delete that group"
    end
    
    redirect_to group
  end
end 