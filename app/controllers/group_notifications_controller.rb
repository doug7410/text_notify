class GroupNotificationsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @group_notification = GroupNotification.create(params.require(:group_notification).permit(:group_id, :group_message))

    if @group_notification.valid?
      @group_notification.group.customers.each do |customer|
        notification = Notification.create(customer_id: customer.id, message: @group_notification.group_message, group_notification_id: @group_notification.id, user_id: current_user.id)

          Notification.delay.send_text(notification.id)
      end

      flash[:success] = "A text has been successfully sent to the \"#{@group_notification.group.name}\" group."
      redirect_to notifications_path
    else
      @notification = Notification.new
      @customers = current_user_customers
      @notifications = Notification.where(user_id: current_user.id)
      @customer = Customer.new
      @groups = current_user.groups.all
      @group = Group.new
      flash[:error] = "There was a problem."
      render 'notifications/index'
    end
  end

private 

  def current_user_customers
    Customer.where("user_id = ?", current_user.id)
  end
end 
