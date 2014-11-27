class GroupNotificationsController < ApplicationController
  before_filter :authenticate_user!

  def create

    @group_notification = GroupNotification.create(params.require(:group_notification).permit(:group_id, :group_message))

    if @group_notification.valid?
      @group_notification.group.customers.each do |customer|
        notification = Notification.new(customer: customer, message: @group_notification.group_message, group_notification: @group_notification)

          handle_sending_text_message(notification)
      end
      flash[:success] = "A text has been successfully sent to the \"#{@group_notification.group.name}\" group."
      redirect_to notifications_path
    else
      @notification = Notification.new
      @customers = current_user_customers
      @notifications = Notification.all
      @customer = Customer.new
      # @notification.customer = Customer.new #TODO : why do I need this?
      @groups = current_user.groups.all
      @group = Group.new
      flash[:error] = "There was a problem."
      render 'notifications/index'
    end
  end

private 

  def handle_sending_text_message(notification)
    result = TwilioWrapper.send_message({
      :to => notification.customer.phone_number,
      :body => notification.message
    })
    if result.successful?
      notification.sid = result.response.sid
      # notification.status = TwilioWrapper.message_status(notification.sid) 
      notification.save
    else
      # notification.status = 'failed'  
      notification.save
    end
  end

  def current_user_customers
    Customer.where("user_id = ?", current_user.id)
  end

  
end 