class NotificationsController < ApplicationController
  before_filter :authenticate_user!, :update_notification_statuses!, :set_up_notification_page
    
  def index
    @notification = Notification.new
    @customer = Customer.new
    @group_notification = GroupNotification.new
  end

  def create
    @notification = Notification.new(notification_params.merge(user_id: current_user.id))
    @customer = Customer.new(customer_params.merge({phone_number: Customer.format_phone_number(customer_params[:phone_number]), user_id: current_user.id}))
    @group_notification = GroupNotification.new
    

    if the_customer_is_missing
      trigger_errors(@notification)
      flash[:error] = "There was a problem."
      render :index
    elsif a_new_customer_is_being_added 
      if @customer.valid?
        @notification.customer = @customer
        if @notification.valid?
          handle_sending_text_message(notification: @notification, customer: @customer)
        else
          flash[:error] = "There was a problem."
          render :index
        end
      else
        @notification.errors.clear
        flash[:error] = "There was a problem."
        render :index
      end
    elsif sending_to_an_existing_customer
      if @notification.valid?
        handle_sending_text_message(notification: @notification)
      else
        flash[:error] = "There was a problem."
        render :index 
      end
    else
      flash[:error] = "There was a problem."
      render :index
    end
  end

  
private

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

  def handle_sending_text_message(options={})
    result = options[:notification].send_text
    
    if result.successful? 
      options[:notification].save_with_status(result)
      options[:customer].save if options[:customer]
      flash[:success] = "A text to #{options[:notification].customer.decorate.name} has been sent!"
      redirect_to notifications_path
    else
      options[:notification].errors[:base] << result.error_message
      render :index 
    end
  end


  def notification_params 
    params.require(:notification).permit(:customer_id, :message)
  end

  def customer_params 
    params.require(:customer).permit(:first_name, :last_name, :phone_number)
  end



end