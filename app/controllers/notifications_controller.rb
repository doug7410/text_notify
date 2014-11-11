class NotificationsController < ApplicationController
  before_filter :authenticate_user!
    
  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.new(notification_params)
    if @notification.save

      send_text_message(@notification) 
 
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

  def send_text_message(notification)
    begin
      client = Twilio::REST::Client.new(ENV['twilio_account_sid'], ENV['twilio_auth_token'])      
      
      client.account.messages.create({
        :from => '+15619238682',  
        :to => notification.customer.phone_number, 
        :body => notification.message  
      })
    rescue Twilio::REST::RequestError => e
      puts e.message
    end
  end
end