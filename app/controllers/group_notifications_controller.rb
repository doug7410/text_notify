class GroupNotificationsController < ApplicationController
  before_filter :authenticate_user!

  def create

    group_notification = GroupNotification.create(params.require(:group_notification).permit(:group_id, :group_message))


    group_notification.group.customers.each do |customer|
      notification = Notification.new(customer: customer, message: group_notification.group_message, group_notification: group_notification)

        handle_sending_text_message(notification: notification)
    end

    redirect_to notifications_path
  end

  def handle_sending_text_message(options={})
    result = send_text_message(options[:notification])
    # if result.successful? 
      options[:notification].sid = result.response.sid
      options[:notification].sent_date = Time.now 
      options[:notification].save
      options[:customer].save if options[:customer]
      flash[:success] = "A text to #{options[:notification].customer.decorate.name} has been sent!"
      # redirect_to notifications_path
    # else
      # options[:notification].errors[:base] << result.error_message
      # render :index 
    # end
  end

  def send_text_message(notification)
    TwilioWrapper::REST::Client.send_message({
      :to => notification.customer.phone_number,
      :body => notification.message
    })
  end
end