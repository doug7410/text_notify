class AddGroupNotificationIdToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :group_notification_id, :integer
  end
end
