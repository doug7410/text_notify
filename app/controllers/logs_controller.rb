class LogsController < ApplicationController
  before_filter :authenticate_business_owner!, :update_notification_statuses!
  
  def index
    @notifications = Notification.where(business_owner_id: current_business_owner.id)
  end
end