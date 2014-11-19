class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout :layout_by_resource

  helper_method :trigger_errors
  
  protected

  def layout_by_resource
    if devise_controller? && resource_name == :user && action_name == "new"
      # false
    else
      "application"
    end
  end

  def trigger_errors(object)
    object.valid?
  end
end
