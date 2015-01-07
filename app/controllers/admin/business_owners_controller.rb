class Admin::BusinessOwnersController < AdminsController
  def index
    @business_owners = BusinessOwner.order(created_at: :desc).all_except(current_business_owner)
  end
end 