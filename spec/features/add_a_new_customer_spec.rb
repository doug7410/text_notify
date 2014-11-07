require 'spec_helper'

feature "Add A New customer" do
  scenario "[a user adds a new customer with valid info]" do
    sign_in_user
    visit new_customer_path
 
    fill_in_customer_form(first_name: 'Freddy', last_name: 'Mercury', phone_number: '555-555-5555')
    expect(page).to have_content("Freddy Mercury has been successfully added")
    expect(current_path).to eq(new_customer_path)
  end

  scenario "[a user adds a new customer with invalid info]" do
    sign_in_user
    visit new_customer_path
    
    fill_in_customer_form()
    expect(page).to have_content("Please fix the errors below.")
    expect(page).to have_content("First name can't be blank")  
    expect(page).to have_content("Last name can't be blank")  
    expect(page).to have_content("Phone number can't be blank")  

    # can you test that a template is rendered here?
    # expect(view).to render_template(:new)
  end


  scenario "[a user adds a new customer with an invalid phone number]" do
    sign_in_user
    visit new_customer_path
    
    fill_in_customer_form(first_name: 'Freddy', last_name: 'Mercury', phone_number: '555-555-555')
    expect(page).to have_content("Please fix the errors below.")
    expect(page).to have_content("please enter a 10 digit")  

    # can you test that a template is rendered here?
    # expect(view).to render_template(:new)
  end
end

def fill_in_customer_form(options={})
    fill_in "First Name", with: options[:first_name]
    fill_in "Last Name", with: options[:last_name]
    fill_in "Phone Number", with: options[:phone_number] 
    click_button "Save Customer"
end