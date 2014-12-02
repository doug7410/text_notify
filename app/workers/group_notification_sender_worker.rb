class GroupNotificationSenderWorker
  include Sidekiq::Worker

  def perform(group_notification_id, business_owner_id)
    group_notification = GroupNotification.find(group_notification_id)

    group_notification.group.customers.each do |customer|
      notification = Notification.create(customer_id: customer.id, message: group_notification.group_message, group_notification_id: group_notification.id, business_owner_id: business_owner_id)
        result = notification.send_text
        notification.save_with_status(result)
    end
  end
end