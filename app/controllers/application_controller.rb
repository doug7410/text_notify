class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :configure_permitted_parameters, if: :devise_controller?

  helper_method :formated_phone_number

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:reset_password) do |u|
      u.permit(:company_name, :email, :password, :password_confirmation)
    end
  end

  def update_notification_statuses!
    return false unless current_business_owner.notifications.any?
    current_business_owner.notifications.each do |n|
      n.update_status!
    end
  end

  def formated_phone_number(phone_number)
    Customer.format_phone_number(phone_number)
  end

  def ensure_admin
    if !current_business_owner.admin? 
      flash[:warning] = "That page is only accessible by admistrators."
      redirect_to root_path
    end
  end

  def check_that_account_settings_are_completed
    if !current_business_owner.account_setting.present?
      flash[:warning] = 'Before you can send any txt messages you need to set up your default messages and time zone'
      redirect_to account_settings_path
    end
  end 
end
