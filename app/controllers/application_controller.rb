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

  def trigger_errors(object)
    object.valid?
  end

  def set_up_notification_page
    @customers = Customer.where("user_id = ?", current_user.id)
    @notifications = Notification.where("user_id = ?", current_user.id)
    @groups = Group.where("user_id = ?", current_user.id)
  end

  def update_notification_statuses!
    Notification.where(user_id: current_user.id).each { |n| n.update_status! }
  end
end
