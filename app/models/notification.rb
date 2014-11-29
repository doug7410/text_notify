class Notification < ActiveRecord::Base
  default_scope -> { order "created_at DESC" }
  scope :delivered, -> { where(status: 'delivered') }
  scope :failed, -> { where.not(status: 'delivered') }
  belongs_to :customer
  belongs_to :user  
  belongs_to :group_notification
  
  validates_presence_of :customer, :user, :message


  def send_text(user)
    result = TwilioWrapper.send_message({
      :to => customer.phone_number,
      :body => message
    })
    if result.successful?
      self.user = user
      self.sid = result.response.sid
      self.save
    else
      self.user = user
      self.status = 'failed'  
      self.save
    end
  end


end