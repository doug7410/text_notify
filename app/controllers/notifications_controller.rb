class NotificationsController < ApplicationController
  before_filter :authenticate_user!
    
  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.new(notification_params)
    
    response = TwilioWrapper::REST::Client.account.messages.create({
        :to => @notification.customer.phone_number)
        :body => @notification.message
      })

    if @notification.save


      # binding.pry
      flash[:success] = "The message has been sent."
      redirect_to new_notification_path
    else 
      render :new
    end
  end

private

  def notification_params 
    params.require(:notification).permit(:customer_id, :message)
  end

end