class GroupNotificationsController < ApplicationController
  before_filter :authenticate_user!

  def create

    group_notification = GroupNotification.create(params.require(:group_notification).permit(:group_id, :group_message))


    group_notification.group.customers.each do |customer|
      Notification.create(customer: customer, message: group_notification.group_message, group_notification: group_notification)
    end

    redirect_to notifications_path
  end
end