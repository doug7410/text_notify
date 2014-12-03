class NotificationsController < ApplicationController
  before_action :authenticate_business_owner!, :update_notification_statuses!, :set_up_notification_page
  before_action :set_up_notification_create, only: [:create]

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
      if customer_and_notification_valid?
        send_text_and_redirect
      else
        @notification.errors.clear
        render :index    
      end 
    elsif sending_to_an_existing_customer
      if @notification.valid?
        send_text_and_redirect
      else
        render :index 
      end
    else
      flash[:error] = "There was a problem."
      render :index
    end
  end

  
private
  def send_text_and_redirect
    result = @notification.send_text
    if result.successful? 
      @notification.save_with_status(result)
    else
      @notification.errors[:base] << result.error_message
    end
    flash[:success] = "A text to #{@notification.customer.decorate.name} has been sent!"
    redirect_to notifications_path
  end
  
  def customer_and_notification_valid?
    ActiveRecord::Base.transaction do
      @customer.save
      @notification.customer = @customer
      @notification.save
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

  def set_up_notification_create
    @group_notification = GroupNotification.new
    @notification = Notification.new(notification_params.merge(business_owner_id: current_business_owner.id))
    @customer = Customer.new(customer_params.merge({phone_number: Customer.format_phone_number(customer_params[:phone_number]), business_owner_id: current_business_owner.id}))
  end
end