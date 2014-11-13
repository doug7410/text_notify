require 'spec_helper'

feature "edit a customer" do
  let(:doug) { Fabricate(:user)}
  background { sign_in_user(doug) }

  given!(:bob) { Fabricate(:customer, first_name: "Bob", last_name: "Smith", phone_number: "5555555555", user: doug).decorate }

  scenario "[a user views a customer page]" do
    visit customers_path
    find("a[id='edit_#{bob.id}']").click
    expect(page).to have_content("Bob Smith")
  end

  scenario "[a user updates a customer with valid info]" do
    visit customer_path(bob.id)

    fill_in_customer_form(first_name: 'Freddy', last_name: 'Mercury', phone_number: '7778889999')
    click_button "Update Customer"
    
    expect(page).to have_content("Customer - Freddy Mercury has been updated.")
    expect(page).to have_selector("input[value='Freddy']")
    expect(page).to have_selector("input[value='Mercury']")
    expect(page).to have_selector("input[value='(777)888-9999']")
  end
  scenario '[a user updates a customer with invalid info]' do
    visit customer_path(bob.id)
    fill_in_customer_form(first_name: '', last_name: '', phone_number: '555555555')
    click_button "Update Customer"
    
    expect(page).to have_content("Please fix the errors below.")
    expect(page).to have_content("First name can't be blank")
    expect(page).to have_content("Last name can't be blank")
    expect(page).to have_content("Phone number is the wrong length (should be 10 characters)")  
  end
end

