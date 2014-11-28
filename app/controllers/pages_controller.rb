class PagesController < ApplicationController
  
  before_filter :authenticate_user!, only: [:dashboard]
  

  def front
    redirect_to dashboard_path if current_user
  end 

  def dashboard
    @customers = current_user.customers.all
    @notifications = all_notifications(@customers)
    @delivered_notifications = current_user.notifications.delivered.all
    @failed_notifications = current_user.notifications.failed.all 
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