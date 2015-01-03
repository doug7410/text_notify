class QueueItem < ActiveRecord::Base
  belongs_to :business_owner
  belongs_to :notification

  def create_new_notification_from_queue_item
    Notification.create(
      business_owner_id: notification.business_owner.id,
      customer: notification.customer,
      order_number: notification.order_number,
      message: notification.business_owner.default_send_from_queue_message
      )
  end
end
