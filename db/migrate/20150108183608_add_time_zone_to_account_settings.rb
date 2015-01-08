class AddTimeZoneToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :timezone, :string
  end
end
