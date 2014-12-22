class AddMessagePrefixToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :default_message_subject, :string
  end
end
