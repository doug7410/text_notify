class GroupNotification < ActiveRecord::Base
  belongs_to :group
  belongs_to :business_owner
  has_many :notifications

  validates_presence_of :group_id, :group_message, :business_owner
end