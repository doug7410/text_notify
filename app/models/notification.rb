class Notification < ActiveRecord::Base
  default_scope -> { order "created_at DESC" }
  scope :delivered, -> { where(status: 'delivered') }
  belongs_to :customer  
  belongs_to :group_notification
  
  validates_presence_of :customer, :message


end