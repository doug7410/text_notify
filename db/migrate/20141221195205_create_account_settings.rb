class CreateAccountSettings < ActiveRecord::Migration
  def change
    create_table :account_settings do |t|
      t.string :default_add_to_queue_message
      t.string :default_send_now_message
      t.string :default_send_from_queue_message
      t.integer :business_owner_id
    end
  end
end
