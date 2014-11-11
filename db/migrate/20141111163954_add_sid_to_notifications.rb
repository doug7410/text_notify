class AddSidToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :sid, :string
  end
end
