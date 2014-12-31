class NotificationsController < ApplicationController
  before_action :authenticate_business_owner!

  def index
    if default_messages_are_set
      @notification = Notification.new
      @customer = Customer.new
      @group_notification = GroupNotification.new
      @queue_items = QueueItem.where(business_owner_id: current_business_owner.id)
      @groups = Group.where("business_owner_id = ?", current_business_owner.id)
    else
      flash[:warning] = 'Before you can send any txt messages you need to set up your default messages'
      redirect_to account_settings_path
    end
  end

  def create
    @customer = Customer.find_or_create_by(phone_number: customer_params[:phone_number], business_owner_id: customer_params[:business_owner_id])
    @customer.update(full_name: customer_params[:full_name])
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
              @success_message = "A txt has been sent!"
              
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
    if queue_item = QueueItem.find_by(id: params[:id])
      notification = Notification.create(business_owner_id: current_business_owner.id, customer: queue_item.notification.customer, order_number:queue_item.notification.order_number, message: current_business_owner.default_send_from_queue_message )
      handle_sending_text_message(notification)
      queue_item.destroy  
      respond_to do |format|
        format.js do
          @success_message = "the queue item has been sent"
          @queue_items = QueueItem.where(business_owner_id: current_business_owner.id)
          render :queue_items
        end
      end
    else
      respond_to do |format|
        format.js do
          @error_message = "the queue item doesn't exist"
          render :queue_items
        end
      end  
    end
  end 

  
  private
  
  def default_messages_are_set
    !!current_business_owner.account_setting
  end

  def handle_queue_items
    if params[:commit] == 'send later'
      QueueItem.create(notification_id: @notification.id, business_owner_id: current_business_owner.id)
    @queue_items = QueueItem.where(business_owner_id: current_business_owner.id)
    end
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
    customer_params = params.require(:customer).permit(:full_name, :phone_number)
    customer_params.merge({phone_number: Customer.format_phone_number(customer_params[:phone_number]), business_owner_id: current_business_owner.id})
  end

  
end
