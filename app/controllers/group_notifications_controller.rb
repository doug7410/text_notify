class GroupNotificationsController < ApplicationController
  before_filter :authenticate_business_owner!

  def create
    @groups = current_business_owner.groups
    @group_notification = GroupNotification.create(group_notification_params)
    if @group_notification.valid?
      @group_notification.save
      GroupNotificationSenderWorker.perform_async(
                                            @group_notification.id,
                                            current_business_owner.id
                                          )
      flash[:success] = "A txt has been successfully sent to the \"#{@group_notification.group.name}\" group."
      render 'notifications/group'
    else
      flash[:error] = 'There was a problem.'
      render 'notifications/group'
    end
  end

  private

  def group_notification_params
    gn_hash = params.require(:group_notification).permit(
                                                      :group_id,
                                                      :group_message
                                                    )
    gn_hash.merge(business_owner_id: current_business_owner.id)
  end
end

