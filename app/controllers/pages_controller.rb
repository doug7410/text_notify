class PagesController < ApplicationController
  
  before_filter :authenticate_user!, only: [:dashboard]
  

  def front
    redirect_to dashboard_path if current_user
  end 

  def dashboard
    @customers = current_user.customers.all
    @notifications = all_notifications(@customers)

    @delivered_notifications = []
    @failed_notifications = []

    @notifications.each do |notification|
      if notification.status ==  'delivered'
        @delivered_notifications << notification
      end
    end

    @notifications.each do |notification|
      if notification.status !=  'delivered'
        @failed_notifications << notification
      end
    end
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