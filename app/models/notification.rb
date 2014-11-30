
class Notification < ActiveRecord::Base
  default_scope -> { order "created_at DESC" }
  scope :delivered, -> { where(status: 'delivered') }
  scope :failed, -> { where.not(status: 'delivered') }
  belongs_to :customer
  belongs_to :user  
  belongs_to :group_notification
  
  validates_presence_of :customer, :user, :message


  def send_text
      TwilioWrapper.send_message({
        :to => customer.phone_number,
        :body => message
      })
  end

  def save_with_status(result)
    if result.successful?
      self.sid = result.response.sid
      self.save
    else
      self.status = 'failed'  
      self.save
    end
  end

  def update_status!
    if (self.sid and self.status == nil) or (self.sid and self.status == 'sent') 
      self.update(status: TwilioWrapper.message_status(sid)) 
    end

  end 


end