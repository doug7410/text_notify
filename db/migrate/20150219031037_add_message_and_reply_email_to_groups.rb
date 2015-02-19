class AddMessageAndReplyEmailToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :reply_message, :string 
    add_column :groups, :forward_email, :string 
  end
end
