class NotificationsController < ApplicationController
  before_filter :authenticate_user!
    
  def index
    @notification = Notification.new
    @customers = current_user_customers
    @notifications = notifications(sent: true)
    @customer = Customer.new
    @notification.customer = Customer.new #TODO : why do I need this?
    @group_notification = GroupNotification.new
    @groups = Group.where("user_id = ?", current_user.id)
    @group = Group.new
  end

  def new
    @notification = Notification.new
    @customers = current_user_customers
  end

  def create
    @notifications = notifications(sent: true)
    @customers = current_user_customers
    @notification = Notification.new(notification_params)
    @customer = Customer.new(customer_params.merge({user_id: current_user.id}))

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
        render :index
      end
    elsif sending_to_an_existing_customer
      if @notification.valid?
        handle_sending_text_message(notification: @notification)
      else
        render :index 
      end
    else
      render :index
    end
  end

  def sent
    @notifications = notifications(sent: true)
  end

  def pending
    @notifications = notifications(sent: false)
  end

  def send_notification

    notification = Notification.find(params[:id])

    if notification.valid?
    
      result = send_text_message(notification)

      if result.successful? 
        notification.sid = result.response.sid
        notification.sent_date = Time.now 
        notification.save
        flash[:success] = "A text to #{notification.customer.decorate.name} has been sent!"
        redirect_to pending_notifications_path
      else
        @notifications = notifications(sent: false)
        flash[:danger] = result.error_message
        render :pending
      end
    end
  end

  def destroy_pending
    
    notification =  Notification.find_by_id(params[:id])

    if notification
      notification.destroy
      @notifications = notifications(sent: false)
      redirect_to pending_notifications_path
    else
      flash[:danger] = "the notification you are trying to delete doesn't exsit or has allredy been deleted"
      @notifications = notifications(sent: false)
      redirect_to pending_notifications_path
    end
  end
  
private

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
      options[:notification].sent_date = Time.now 
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

  def notifications(options={})
    notifications = []
    current_user.customers.each do |customer|
      customer.notifications.each do |note|
        if options[:sent]
          notifications << note if note.sid.present?
        else
          notifications << note if note.sid.nil?
        end
      end
    end
    notifications
  end


  def notification_params 
    params.require(:notification).permit(:customer_id, :message)
  end

  def customer_params 
    params.require(:customer).permit(:first_name, :last_name, :phone_number)
  end

  def save_without_sending(notification)
    notification.save
    flash[:success] = "The message has been saved."
    redirect_to new_notification_path
  end

  def send_text_message(notification)
    TwilioWrapper::REST::Client.send_message({
      :to => notification.customer.phone_number,
      :body => notification.message
    })
  end

end