require 'spec_helper'

feature "Add A New customer" do
  scenario "[a business_owner adds a new customer with valid info]" do
    sign_in_business_owner
    visit new_customer_path
 
    fill_in_customer_form(first_name: 'Freddy', last_name: 'Mercury', phone_number: '5555555555')
    click_button "Save Customer"
    
    expect(page).to have_content("Freddy Mercury has been successfully added")
    expect(current_path).to eq(customers_path)
  end

  scenario "[a business_owner adds a new customer with invalid info]" do
    sign_in_business_owner
    visit new_customer_path
    
    fill_in_customer_form()
    click_button "Save Customer"
    
    expect(page).to have_content("Please fix the errors below.")
    expect(page).to have_content("First name can't be blank")  
    expect(page).to have_content("Last name can't be blank")  
    expect(page).to have_content("Phone number can't be blank")  

  end


  scenario "[a business_owner adds a new customer with an invalid phone number]" do
    sign_in_business_owner
    visit new_customer_path
    
    fill_in_customer_form(first_name: 'Freddy', last_name: 'Mercury', phone_number: '555555555')
    click_button "Save Customer"
    
    expect(page).to have_content("Phone number is the wrong length (should be 10 characters)")  
  end
end
