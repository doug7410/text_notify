class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :customer_id
      t.string :message
      t.timestamps
    end
  end
end
