class AddAdminToBusinessOwners < ActiveRecord::Migration
  def change
    add_column :business_owners, :admin, :boolean
  end
end
