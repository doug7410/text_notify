class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  before_action :update_notification_statuses!
    
  def index
    @notification = Notification.new
    @customers = current_user_customers
    @notifications = Notification.where(user_id: current_user.id)
    @customer = Customer.new
    @notification.customer = Customer.new #TODO : why do I need this?
    @group_notification = GroupNotification.new
    @groups = Group.where("user_id = ?", current_user.id)
    @group = Group.new
  end

  def create
    @notifications = Notification.where(user_id: current_user.id)
    @customers = current_user_customers
    @notification = Notification.new(notification_params.merge(user_id: current_user.id))
    @customer = Customer.new(customer_params.merge({phone_number: Customer.format_phone_number(customer_params[:phone_number]), user_id: current_user.id}))
    @group_notification = GroupNotification.new
    @groups = Group.where("user_id = ?", current_user.id)
    @group = Group.new

    if the_customer_is_missing
      trigger_errors(@notification)
      render :index
    elsif a_new_customer_is_being_added 
      if @customer.valid?
        @notification.customer = @customer
        if @notification.valid?
          handle_sending_text_message(notification: @notification, customer: @customer)
        else
          render :index
        end
      else
        @notification.errors.clear
        flash[:error] = "There was a problem."
        render :index
      end
    elsif sending_to_an_existing_customer
        # binding.pry
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

  def update_notification_statuses!
    Notification.where(user_id: current_user.id).each { |n| n.update_status! }
  end

  def sending_to_an_existing_customer
    notification_params[:customer_id]
  end
  
  def a_new_customer_is_being_added
    notification_params[:customer_id].empty? && new_customer_form_not_empty?
  end
  
  def the_customer_is_missing
    notification_params[:customer_id].empty? && !new_customer_form_not_empty?
  end
  
  def handle_sending_text_message(options={})
    result = send_text_message(options[:notification])
    if result.successful? 
      options[:notification].sid = result.response.sid
      options[:notification].save
      options[:customer].save if options[:customer]
      flash[:success] = "A text to #{options[:notification].customer.decorate.name} has been sent!"
      redirect_to notifications_path
    else
      options[:notification].errors[:base] << result.error_message
      render :index 
    end
  end

  def new_customer_form_not_empty?
    customer = customer_params[:first_name]
    customer += customer_params[:last_name]
    customer += customer_params[:phone_number]
    !customer.empty?
  end

  def current_user_customers
    Customer.where("user_id = ?", current_user.id)
  end

  def notification_params 
    params.require(:notification).permit(:customer_id, :message)
  end

  def customer_params 
    params.require(:customer).permit(:first_name, :last_name, :phone_number)
  end

  def send_text_message(notification)
    TwilioWrapper.send_message({
      :to => notification.customer.phone_number,
      :body => notification.message
    })
  end

end