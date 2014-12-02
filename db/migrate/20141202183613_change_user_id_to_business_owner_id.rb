class ChangeUserIdToBusinessOwnerId < ActiveRecord::Migration
  def change
    rename_column :customers, :user_id, :business_owner_id 
    rename_column :groups, :user_id, :business_owner_id 
    rename_column :notifications, :user_id, :business_owner_id 
  end
end
