class RenameCustomerGroupToMembership < ActiveRecord::Migration
  def change
    rename_table :customer_groups, :memberships 
  end
end
