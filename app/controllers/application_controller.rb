class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  helper_method :trigger_errors
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:reset_password) { |u| u.permit(:full_name, :email, :password, :password_confirmation) }
  end

  def set_up_notification_page
    @customers = Customer.where("business_owner_id = ?", current_business_owner.id)
    @notifications = Notification.where("business_owner_id = ?", current_business_owner.id)
    @groups = Group.where("business_owner_id = ?", current_business_owner.id)
  end

  def update_notification_statuses!
    Notification.where(business_owner_id: current_business_owner.id).each { |n| n.update_status! }
  end
end
