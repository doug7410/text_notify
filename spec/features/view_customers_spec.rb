require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!
  
feature "[View the customers in the database]" do
  let(:doug) { Fabricate(:business_owner)}
  background {login_as doug, scope: :business_owner, run_callbacks: false}

  scenario "a business_owner views the customers" do
    bob = Fabricate(:customer, first_name: "Bob", last_name: "Smith", phone_number: "5554447777", business_owner: doug)
    jane = Fabricate(:customer, first_name: "Jane", last_name: "Doe", phone_number: "5554449999", business_owner: doug)
 
    visit customers_path 

    expect(page).to have_content("Bob Smith")
    expect(page).to have_content("(555)444-7777")
    expect(page).to have_content("Jane Doe")
    expect(page).to have_content("(555)444-9999")
  end
end