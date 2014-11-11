class Notification < ActiveRecord::Base
  belongs_to :customer  

  validates_presence_of :customer, :message

end