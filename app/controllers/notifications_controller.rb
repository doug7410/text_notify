class NotificationsController < ApplicationController
  before_action :authenticate_business_owner!, :set_up_notification_page
  before_action :set_up_create_action, only: [:create]

  def index
    @notification = Notification.new
    @customer = Customer.new
    @group_notification = GroupNotification.new
  end

  def create
    if the_customer_is_missing
      @notification.errors[:base] << "Please choose a customer or add a new one."
      render :index
    elsif a_new_customer_is_being_added 
      if @customer.valid?
        send_text_if_notification_and_customer_valid!
        flash[:success] = "A txt has been sent!"
        @notification = Notification.new
      else
        @notification.errors.clear
      end
    elsif sending_to_an_existing_customer
      respond_to do |format|
        format.js do
          if @notification.valid?
            handle_sending_text_message(notification: @notification)
            flash[:success] = "A txt has been sent!"
            @notification = Notification.new
          end
        end
      end
    else
      flash[:error] = "There was a problem. The notification could not be sent."
      render :index
    end
  end

  
private
  
  def send_text_if_notification_and_customer_valid!
    @notification.customer = @customer
    if @notification.message.present?
      handle_sending_text_message(notification: @notification, customer: @customer)
    else
      @notification.valid?
      nil
    end
  end

  def handle_sending_text_message(options={})
    result = options[:notification].send_text
    if result.successful? 
      if options[:customer]
        options[:customer].save 
        options[:notification].customer = options[:customer]
      end

      options[:notification].save_with_status(result)
    else
      options[:notification].errors[:base] << result.error_message
      render :index 
    end
  end

  def sending_to_an_existing_customer
    !!notification_params[:customer_id]
  end
  
  def a_new_customer_is_being_added
    notification_params[:customer_id].empty? && new_customer_form_not_empty?
  end
  
  def the_customer_is_missing
    notification_params[:customer_id].empty? && !new_customer_form_not_empty?
  end
  
  def new_customer_form_not_empty?
    customer = customer_params[:first_name]
    customer += customer_params[:last_name]
    customer += customer_params[:phone_number]
    !customer.empty?
  end



  def notification_params 
    params.require(:notification).permit(:customer_id, :message)
  end

  def customer_params 
    params.require(:customer).permit(:first_name, :last_name, :phone_number)
  end

  def set_up_create_action
    @notification = Notification.new(notification_params.merge(business_owner_id: current_business_owner.id))
    @customer = Customer.new(customer_params.merge({phone_number: Customer.format_phone_number(customer_params[:phone_number]), business_owner_id: current_business_owner.id}))
    @group_notification = GroupNotification.new
  end


end