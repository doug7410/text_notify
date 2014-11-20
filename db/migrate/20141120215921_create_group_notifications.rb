class CreateGroupNotifications < ActiveRecord::Migration
  def change
    create_table :group_notifications do |t|
      t.integer :group_id
      t.string :group_message
      t.timestamps
    end
  end
end
