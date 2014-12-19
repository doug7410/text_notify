class AddOrderNumberToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :order_number, :string
  end
end
