class AddFullNameToBusinessOwners < ActiveRecord::Migration
  def change
    add_column :business_owners, :full_name, :string
  end
end
