class BusinessOwners::RegistrationsController < Devise::RegistrationsController
before_filter :configure_sign_up_params, only: [:create]
before_filter :configure_account_update_params, only: [:update]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :company_name
  end
  
  def configure_account_update_params
    devise_parameter_sanitizer.for(:account_update) << :company_name
  end

end
