class BusinessOwner < ActiveRecord::Base
  has_many :customers
  has_many :notifications
  has_many :group_notifications
  has_many :groups
  has_many :group_notifications, through: :groups
  has_one :account_setting

  delegate :default_message_subject, to: :account_setting
  delegate :default_send_now_message, to: :account_setting
  delegate :default_add_to_queue_message, to: :account_setting
  delegate :default_send_from_queue_message, to: :account_setting

  validates :full_name, presence: true
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
