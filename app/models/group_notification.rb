class GroupNotification < ActiveRecord::Base
  belongs_to :group
  has_many :notifications do  
    def sent
      sent_notifications = []
      self.each do |notification|
        sent_notification = notification if notification.sid.present?
        sent_notifications << sent_notification
      end
      sent_notifications
    end
  end

  validates_presence_of :group_id, :group_message
end