class NotificationsController < ApplicationController
  before_filter :authenticate_user!
    
  def index
    @notification = Notification.new
    @customers = current_user_customers
    @notifications = notifications(sent: true)
    @customer = Customer.new
    
  end

  def new
    @notification = Notification.new
    @customers = current_user_customers
  end

  def create
    @notification = Notification.new(notification_params)
    @customers = current_user_customers

    if @notification.valid?
      
      if params[:do_not_send]
        save_without_sending(@notification)
      else
        result = send_text_message(@notification)

        if result.successful? 
          @notification.sid = result.response.sid
          @notification.sent_date = Time.now 
          @notification.save
          flash[:success] = "The message has been sent."
          redirect_to new_notification_path
        else
          flash[:danger] = result.error_message
          render :new
        end
      end
    else
      render :new
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