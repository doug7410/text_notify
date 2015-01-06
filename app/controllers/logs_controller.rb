class LogsController < ApplicationController
  before_filter :authenticate_business_owner!, :update_notification_statuses!
  
  def index
    id = current_business_owner.id
    notifications = Notification.where(business_owner_id: id)
    @notifications = notifications.paginate(page: params[:page])
  end
end