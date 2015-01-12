class PagesController < ApplicationController
  
  before_filter :authenticate_business_owner!, only: [:dashboard]
  before_action :check_that_account_settings_are_completed, only: [:dashboard]
  

  def front
    redirect_to dashboard_path if current_business_owner
  end 

  def dashboard
    @customers_count = current_business_owner.customers.all.count
    @delivered_notifications_count = current_business_owner.notifications.delivered.all.count
    @failed_notifications_count = current_business_owner.notifications.failed.all.count 
  end
end