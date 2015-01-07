class Admin::BusinessOwnersController < AdminsController
  def index
    @business_owners = BusinessOwner.all_except(current_business_owner)
  end
end 