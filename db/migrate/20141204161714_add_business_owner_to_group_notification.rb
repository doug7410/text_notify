class AddBusinessOwnerToGroupNotification < ActiveRecord::Migration
  def change
    add_column :group_notifications, :business_owner_id, :integer
  end
end
