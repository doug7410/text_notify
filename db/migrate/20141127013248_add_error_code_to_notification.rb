class AddErrorCodeToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :error_code, :string
  end
end
