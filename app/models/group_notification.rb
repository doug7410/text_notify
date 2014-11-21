class GroupNotification < ActiveRecord::Base
  belongs_to :group

  validates_presence_of :group_id, :group_message
end