class NotificationsController < ApplicationController
  before_filter :authenticate_user!
    
  def index
    @notification = Notification.new
    @customers = current_user_customers
    @notifications = notifications(sent: true)
    @customer = Customer.new
    @notification.customer = Customer.new
    
  end

  def new
    @notification = Notification.new
    @customers = current_user_customers
  end

  def create

    # if customer_id is empty and none of the customer
    # fields are filled in it should say "the customer
    # can't be empty" and ignore validation errors 
    # on the new customer form
    # 
    # if the customer_id is present it should ignore 
    # errors on the new customer form
    # 
    # if the customer_id is empty and any of the new
    # customer fields are filled out it should display 
    # validation errors on the new customer, but not
    #  display a "customer cant be empty" message from
    #   the notification validations

    # binding.pry
    @notification = Notification.new(notification_params)
    @notifications = notifications(sent: true)
    @customers = current_user_customers
    @customer = Customer.new
    # # @customer = Customer.find_by_id(notification_params[:customer_id])

    # binding.pry
    if notification_params[:customer_id].empty? and new_customer_form_not_empty?
      # binding.pry 
      @customer.update(customer_params.merge({user_id: current_user.id}))
      @customer.valid?
      # binding.pry
      @notification.customer = @customer
    else
      @customer = Customer.find(notification_params[:customer_id])
    end
    
    # binding.pry
    
    if @notification.valid? && @customer.valid?
    #   if params[:do_not_send]
    #     save_without_sending(@notification)
        result = send_text_message(@notification)

        if result.successful? 
          @notification.sid = result.response.sid
          @notification.sent_date = Time.now 
          @notification.save
          flash[:success] = "The message has been sent."
          redirect_to notifications_path
        else
          flash[:danger] = result.error_message
          render :index
        end
    #   end
    # else
    #   # binding.pry
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
        flash[:success] = "The message has been sent."
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