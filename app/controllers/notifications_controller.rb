class NotificationsController < ApplicationController
  before_action :authenticate_business_owner!
  before_action :set_queue_items_for_current_business_owner
  before_action :check_that_account_settings_are_completed, only: [:index]

  def index
    @notification = Notification.new
    @customer = Customer.new
    @group_notification = GroupNotification.new
    @groups = set_groups_for_current_business_owner
  end

  def create
    @customer = Customer.find_or_create_by(customer_phone_and_business_owner)
    update_name_if_provided(@customer)
    @notification = Notification.new(notification_params)
    choose_default_message(@notification) if @notification.message.blank?

    respond_to do |format|
      format.js do
        unless @customer.valid?
          @notification.errors.clear
          render :create        
        end
       
        if @notification.valid?
          handle_sending_text_message(@notification)
          if @notification.errors[:base].empty?
            @success_message = 'A txt has been sent!'
            handle_adding_queue_items
            @notification = Notification.new
            @customer = Customer.new
            render :create
          else
            @customer = reset_the_customer_with_a_blank_phone_number
          end
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
        else
          @error_message = "the queue item doesn't exist"
        end
        render :queue_items
      end
    end
  end

  private

  def reset_the_customer_with_a_blank_phone_number
    @customer.destroy
    Customer.new(
      full_name: customer_params[:full_name],
      business_owner_id: current_business_owner.id)
  end

  def choose_default_message(notification)
    if params[:commit] == 'send later'
      notification.message = current_business_owner.default_add_to_queue_message
    else
      notification.message = current_business_owner.default_send_now_message
    end
  end

  def  update_name_if_provided(customer)
    return false unless customer_params[:full_name].present?
    customer.update(full_name: customer_params[:full_name])
  end

  def customer_phone_and_business_owner
    { phone_number: customer_params[:phone_number],
      business_owner_id: customer_params[:business_owner_id] }
  end

  def set_queue_items_for_current_business_owner
    @queue_items = QueueItem.where(business_owner_id: current_business_owner.id)
  end

  def set_groups_for_current_business_owner
    Group.where(business_owner_id: current_business_owner.id)
  end

  def handle_adding_queue_items
    return false unless params[:commit] == 'send later'
    QueueItem.create(
      notification_id: @notification.id,
      business_owner_id: current_business_owner.id
    )
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
    notification_hash = params.require(
                          :notification
                        ).permit(
                          :order_number,
                          :message
                        )
    notification_hash.merge(
      business_owner_id: current_business_owner.id,
      customer_id: @customer.id)
  end

  def customer_params
    customer_params = params.require(
                        :customer
                      ).permit(
                        :full_name,
                        :phone_number
                      )

    customer_params.merge(
      phone_number: formated_phone_number(customer_params[:phone_number]),
      business_owner_id: current_business_owner.id)
  end
end
