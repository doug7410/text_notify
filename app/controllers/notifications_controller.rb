class NotificationsController < ApplicationController
  before_action :authenticate_business_owner!, :set_up_notification_page
  before_action :set_up_create_action, only: [:create]

  def index
    @notification = Notification.new
    @customer = Customer.new
    @group_notification = GroupNotification.new
    @queue_items = QueueItem.where(business_owner_id: current_business_owner.id)
  end

  def create
    @customers.where(business_owner_id: current_business_owner.id).all

    @customer = Customer.find_or_create_by(phone_number: customer_params[:phone_number], business_owner_id: customer_params[:business_owner_id])
    @customer.update(full_name: customer_params[:full_name])
    @notification = Notification.new(notification_params.merge(business_owner_id: current_business_owner.id))
    @notification.customer = @customer

    respond_to do |format|
      format.js do
        if @customer.valid?
          if @notification.valid?            
            handle_sending_text_message(@notification)
            if @notification.errors[:base].empty?
              flash[:success] = "A txt has been sent!"
              
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

  
private

  def handle_queue_items
    if params[:commit] == 'send later'
      QueueItem.create(notification_id: @notification.id, business_owner_id: current_business_owner.id)
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

  def set_up_create_action
    @group_notification = GroupNotification.new
  end


end