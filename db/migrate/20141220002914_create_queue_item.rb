class CreateQueueItem < ActiveRecord::Migration
  def change
    create_table :queue_items do |t|
      t.integer :notification_id
      t.integer :business_owner_id
      t.boolean :sent
      t.timestamps
    end
  end
end
