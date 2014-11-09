class NotificationsController < ApplicationController
  before_filter :authenticate_user!
    
  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.new(notification_params)
    if @notification.save

      @notification.send_text_message 
 
      flash[:success] = "The message has been sent."
      redirect_to new_notification_path
    else 
      render :new
    end
  end

  def notification_params 
    params.require(:notification).permit(:customer_id, :message)
  end
end