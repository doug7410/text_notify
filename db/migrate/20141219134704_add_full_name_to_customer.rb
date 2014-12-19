class AddFullNameToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :full_name, :string
  end
end
