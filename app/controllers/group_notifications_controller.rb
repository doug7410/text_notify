class GroupNotificationsController < ApplicationController
  before_filter :authenticate_user!, :update_notification_statuses!, :set_up_notification_page


  def create
    @group_notification = GroupNotification.create(params.require(:group_notification).permit(:group_id, :group_message))

    if @group_notification.valid?
      flash[:success] = "A text has been successfully sent to the \"#{@group_notification.group.name}\" group."
      redirect_to notifications_path
      send_text_to_each_customer_in_group
    else
      @notification = Notification.new
      @customer = Customer.new
      flash[:error] = "There was a problem."
      render 'notifications/index'
    end
  end

private 

  def send_text_to_each_customer_in_group
    @group_notification.group.customers.each do |customer|
      notification = Notification.create(customer_id: customer.id, message: @group_notification.group_message, group_notification_id: @group_notification.id, user_id: current_user.id)
        result = notification.send_text
        notification.save_with_status(result)
    end
  end

  
end 
