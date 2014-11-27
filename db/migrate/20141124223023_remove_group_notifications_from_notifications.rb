class RemoveGroupNotificationsFromNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :group_notification_id
  end
end
