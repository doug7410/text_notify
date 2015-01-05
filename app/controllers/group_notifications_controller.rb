class GroupNotificationsController < ApplicationController
  before_filter :authenticate_business_owner!


  def create
    respond_to do |format|
      format.js do
        @group_notification = GroupNotification.create(params.require(:group_notification).permit(:group_id, :group_message).merge(business_owner_id: current_business_owner.id))
        if @group_notification.valid?
          @group_notification.save
          GroupNotificationSenderWorker.perform_async(@group_notification.id, current_business_owner.id)
          flash[:success] = "A text has been successfully sent to the \"#{@group_notification.group.name}\" group."
          render 'notifications/group'
        else
          @notification = Notification.new
          @customer = Customer.new
          flash[:error] = "There was a problem."
          render 'notifications/group'
        end
      end
    end
  end

private 

  

  
end 
