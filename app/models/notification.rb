class Notification < ActiveRecord::Base
  belongs_to :customer  
  belongs_to :group_notification
  
  validates_presence_of :customer, :message


end