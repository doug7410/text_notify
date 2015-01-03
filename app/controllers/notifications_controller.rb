class NotificationsController < ApplicationController
  before_action :authenticate_business_owner!

  def index
    if default_messages_are_set
      set_new_objects_for_notification_forms
      @queue_items = set_queue_items
      @groups = Group.where(business_owner_id: current_business_owner.id)
    else
      flash[:warning] = 'Before you can send any txt messages
                         you need to set up your default messages'
      redirect_to account_settings_path
    end
  end

  def create
    @customer = Customer.find_or_create_by(phone_and_business_owner)
    @customer.update(full_name: customer_params[:full_name]) if customer_params[:full_name].present?
    # binding.pry

    @notification = Notification.new(notification_params.merge(business_owner_id: current_business_owner.id))
    @notification.customer = @customer

    if @notification.message.blank?
      if params[:commit] == 'send later'
        @notification.message = current_business_owner.default_add_to_queue_message
      else
        @notification.message = current_business_owner.default_send_now_message
      end
    end

    respond_to do |format|
      format.js do
        if @customer.valid?
          if @notification.valid?
            handle_sending_text_message(@notification)
            if @notification.errors[:base].empty?
              @success_message = 'A txt has been sent!'

              handle_queue_items

              @notification = Notification.new
              @customer = Customer.new
              render :create
            else
              @customer.destroy
              @customer = Customer.new(full_name: customer_params[:full_name], business_owner_id: current_business_owner.id)
            end
          end
        else
          @notification.errors.clear
          render :create
        end
      end
    end
  end

  def send_queue_item
    queue_item = QueueItem.find_by(id: params[:id])
    respond_to do |format|
      format.js do
        if queue_item.present?
          notification = queue_item.create_new_notification_from_queue_item
          handle_sending_text_message(notification)
          queue_item.destroy
          @success_message = 'the queue item has been sent'
          @queue_items = set_queue_items
        else
          @error_message = "the queue item doesn't exist"
        end
        render :queue_items
      end
    end
  end

  private

  def phone_and_business_owner
    { phone_number: customer_params[:phone_number],
      business_owner_id: customer_params[:business_owner_id] }
  end

  def set_queue_items
    QueueItem.where(business_owner_id: current_business_owner.id)
  end

  def set_new_objects_for_notification_forms
    @notification = Notification.new
    @customer = Customer.new
    @group_notification = GroupNotification.new
  end

  def default_messages_are_set
    return true if current_business_owner.account_setting.present?
  end

  def handle_queue_items
    return false unless params[:commit] == 'send later'
    QueueItem.create(
      notification_id: @notification.id,
      business_owner_id: current_business_owner.id
      )
    @queue_items = set_queue_items
  end

  def handle_sending_text_message(notification)
    result = notification.send_text
    if result.successful?
      notification.save_with_status(result)
    else
      notification.errors[:base] << result.error_message
    end
  end

  def notification_params
    params.require(:notification).permit(:order_number, :message)
  end

  def customer_params
    customer_params = params.require(:customer).permit(
                                                  :full_name,
                                                  :phone_number)
    customer_params.merge(
      phone_number: formated_phone_number(customer_params[:phone_number]),
      business_owner_id: current_business_owner.id)
  end
end
