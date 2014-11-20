class CreateCustomerGroups < ActiveRecord::Migration
  def change
    create_table :customer_groups do |t|
      t.integer :customer_id
      t.integer :group_id
    end
  end
end
