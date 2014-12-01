class GroupNotification < ActiveRecord::Base
  belongs_to :group
  has_many :notifications

  validates_presence_of :group_id, :group_message
end