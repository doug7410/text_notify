class PagesController < ApplicationController
  
  before_filter :authenticate_business_owner!, only: [:dashboard]
  

  def front
    redirect_to dashboard_path if current_business_owner
  end 

  def dashboard
    @customers = current_business_owner.customers.all
    @notifications = all_notifications(@customers)
    @delivered_notifications = current_business_owner.notifications.delivered.all
    @failed_notifications = current_business_owner.notifications.failed.all 
  end

private

  def all_notifications(customers)
    notifications = []
      
    customers.each do |customer|
      customer.notifications.each do |notification|
        notifications << notification
      end
    end
    notifications
  end

end