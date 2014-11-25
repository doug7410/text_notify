class GroupNotificationsController < ApplicationController
  before_filter :authenticate_user!

  def create

    group_notification = GroupNotification.create(params.require(:group_notification).permit(:group_id, :group_message))


    group_notification.group.customers.each do |customer|
      notification = Notification.new(customer: customer, message: group_notification.group_message, group_notification: group_notification)

        handle_sending_text_message(notification)
    end

    redirect_to notifications_path
  end

private 

  def handle_sending_text_message(notification)
    result = TwilioWrapper::REST::Client.send_message({
      :to => notification.customer.phone_number,
      :body => notification.message
    })

    notification.sid = result.response.sid
    notification.sent_date = Time.now 
    notification.save
  end
end 