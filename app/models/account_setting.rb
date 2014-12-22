class AccountSetting < ActiveRecord::Base
  belongs_to :business_owner

  validates_presence_of :default_send_now_message, :default_add_to_queue_message, :default_send_from_queue_message

end