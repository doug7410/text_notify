class GroupNotificationsController < ApplicationController
  before_filter :authenticate_business_owner!, :update_notification_statuses!, :set_up_notification_page


  def create
    @group_notification = GroupNotification.create(params.require(:group_notification).permit(:group_id, :group_message))

    if @group_notification.valid?
      @group_notification.save
      GroupNotificationSenderWorker.perform_async(@group_notification.id, current_business_owner.id)
      flash[:success] = "A text has been successfully sent to the \"#{@group_notification.group.name}\" group."
      redirect_to notifications_path
    else
      @notification = Notification.new
      @customer = Customer.new
      flash[:error] = "There was a problem."
      render 'notifications/index'
    end
  end

private 

  

  
end 
