require 'spec_helper'

feature "View the customers in the database" do
  scenario "a user views the customers" do
    bob = Fabricate(:customer, first_name: "Bob", last_name: "Smith", phone_number: "555-444-7777")
    jane = Fabricate(:customer, first_name: "Jane", last_name: "Doe", phone_number: "555-444-9999")
 
    sign_in_user    
    visit customers_path 

    expect(page).to have_content("Bob Smith")
    expect(page).to have_content("555-444-7777")
    expect(page).to have_content("Jane Doe")
    expect(page).to have_content("555-444-9999")
  end
end