
class Notification < ActiveRecord::Base
  default_scope -> { order "created_at DESC" }
  scope :delivered, -> { where(status: 'delivered') }
  scope :failed, -> { where.not(status: 'delivered') }
  belongs_to :customer
  belongs_to :user  
  belongs_to :group_notification
  
  validates_presence_of :customer, :user, :message


  def self.send_text(notification_id)
    notification = self.find(notification_id)
    result = TwilioWrapper.send_message({
      :to => notification.customer.phone_number,
      :body => notification.message
    })
    if result.successful?
      notification.sid = result.response.sid
      notification.save
    else
      notification.status = 'failed'  
      notification.save
    end
  end

  def update_status
    if (self.sid and self.status == nil) or (self.sid and self.status == 'sent') 
      self.update(status: TwilioWrapper.message_status(sid)) 
    end

  end 


end