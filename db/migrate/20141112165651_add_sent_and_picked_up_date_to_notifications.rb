class AddSentAndPickedUpDateToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :sent_date, :datetime 
    add_column :notifications, :item_picked_up_date, :datetime 
  end
end
