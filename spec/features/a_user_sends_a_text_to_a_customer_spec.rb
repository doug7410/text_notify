require 'spec_helper'

feature "Sent a text to an individual customer" do 
  scenario '[send a text to an existing customer with valid input]', :vcr do
    bob = Fabricate(:user)
    tom = Fabricate(:customer, user: bob).decorate 
    sign_in_user(bob)  
    visit notifications_path
    select tom.id, :from => "Choose an existing customer"
    fill_in "Message", with: "I'm a message!"
    click_button "Send Notification" 
    expect(page).to have_content("A text to #{tom.name} has been sent!")
  end 

  scenario '[send a text to a new customer with valid input]' 

  scenario '[send a text to an new customer with invalid input]'

  scenario '[send a text without specifying a new customer and leaving new customer flields blank]'

  # scenario "[a user adds a new customer with valid info]" do
  #   sign_in_user
  #   visit new_customer_path
 
  #   fill_in_customer_form(first_name: 'Freddy', last_name: 'Mercury', phone_number: '5555555555')
  #   click_button "Save Customer"
    
  #   expect(page).to have_content("Freddy Mercury has been successfully added")
  #   expect(current_path).to eq(new_customer_path)
  # end

  # scenario "[a user adds a new customer with invalid info]" do
  #   sign_in_user
  #   visit new_customer_path
    
  #   fill_in_customer_form()
  #   click_button "Save Customer"
    
  #   expect(page).to have_content("Please fix the errors below.")
  #   expect(page).to have_content("First name can't be blank")  
  #   expect(page).to have_content("Last name can't be blank")  
  #   expect(page).to have_content("Phone number can't be blank")  

  # end


  # scenario "[a user adds a new customer with an invalid phone number]" do
  #   sign_in_user
  #   visit new_customer_path
    
  #   fill_in_customer_form(first_name: 'Freddy', last_name: 'Mercury', phone_number: '555555555')
  #   click_button "Save Customer"
    
  #   expect(page).to have_content("Phone number is the wrong length (should be 10 characters)")  
  # end
end
