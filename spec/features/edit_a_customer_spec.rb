require 'spec_helper'

feature "edit a customer" do

  background { sign_in_user }

  given!(:bob) { Fabricate(:customer, first_name: "Bob", last_name: "Smith", phone_number: "555-555-5555").decorate }

  scenario "[a user views a customer page]" do
    visit customers_path
    find("a[id='edit_#{bob.id}']").click
    expect(page).to have_content("Bob Smith")
  end

  scenario "[a user updates a customer with valid info]" do
    visit customer_path(bob.id)

    fill_in_customer_form(first_name: 'Freddy', last_name: 'Mercury', phone_number: '777-888-9999')
    click_button "Update Customer"
    
    expect(page).to have_content("Customer - Freddy Mercury has been updated.")
    expect(page).to have_selector("input[value='Freddy']")
    expect(page).to have_selector("input[value='Mercury']")
    expect(page).to have_selector("input[value='(777)888-9999']")
  end
  scenario '[a user updates a customer with invalid info]' do
    visit customer_path(bob.id)
    fill_in_customer_form(first_name: '', last_name: '', phone_number: '555-555-555')
    click_button "Update Customer"
    
    expect(page).to have_content("Please fix the errors below.")
    expect(page).to have_content("First name can't be blank")
    expect(page).to have_content("Last name can't be blank")
    expect(page).to have_content("please enter a 10 digit")  
  end
end

