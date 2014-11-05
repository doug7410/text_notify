require 'rails_helper'

feature "Add A New customer" do
  scenario "[a user adds a new customer with valid info]" do
    bob = Fabricate(:user)
    visit new_user_session_path
 
    fill_in "user_email", with: bob.email
    fill_in "user_password", with: bob.password
    click_button "Login"
    expect(page).to have_content("Signed in successfully.")

    visit new_customer_path
 
    fill_in "First Name", with: "Freddy"
    fill_in "Last Name", with: "Mercury"
    fill_in "Phone Number", with: "555-555-5555" 
    click_button "Save Customer"
    expect(page).to have_content("Fredy Mercury has been successfully added.")

    
  end
end
