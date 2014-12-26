class ChangeBusinessOwnerNameToCompanyName < ActiveRecord::Migration
  def change
    rename_column :business_owners, :full_name, :company_name
  end
end
