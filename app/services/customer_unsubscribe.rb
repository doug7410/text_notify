class CustomerUnsubscribe

  def initialize(phone_number)
    @phone_number = phone_number
    unsubscibe_customer!
  end 

  def unsubscibe_customer!
    customer_occurences = Customer.where(phone_number: @phone_number)
    customer_occurences.each  do |customer| 
      customer.notifications.all.each do |notification| 
        destroy_assoc_queue_item(notification)
        notification.destroy 
      end
      customer.destroy 
    end
  end

  private

  def destroy_assoc_queue_item(notification)
    queue_item = QueueItem.find_by(notification: notification)
    queue_item.destroy if queue_item
  end
end