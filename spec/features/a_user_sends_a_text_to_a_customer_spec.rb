require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!
  
  
feature "Sent a text to an individual customer" do 
  let(:doug) { Fabricate(:business_owner)}
  background {login_as doug, scope: :business_owner, run_callbacks: false}

  scenario '[send a text to an existing customer with valid input]', :vcr do
    tom = Fabricate(:customer, business_owner: doug).decorate 
    visit notifications_path
    select tom.id, :from => "Choose an existing customer"
    fill_in "Message", with: "I'm a message!"
    click_button "Send Notification" 
    expect(page).to have_content("A text to #{tom.name} has been sent!")
  end 

  scenario '[send a text to a new customer with valid input]', :vcr do
    visit notifications_path
    fill_in_notification_form(first_name: "John", last_name: "Doe", phone_number: "9546381523", message: "I'm a message!") 
    click_button "Send Notification" 
    expect(page).to have_content("A text to John Doe has been sent!")
  end
 
  scenario '[send a text to an new customer with invalid input]', :vcr do
    visit notifications_path
    fill_in_notification_form(first_name: "", last_name: "Doe", phone_number: "9546381523", message: "I'm a message!") 
    click_button "Send Notification" 
    expect(page).to have_content("First name can't be blank")

    fill_in_notification_form(first_name: "John", last_name: "Doe", phone_number: "9546381523", message: "") 
    click_button "Send Notification"
    # save_and_open_page 
    expect(page).to have_content("Message can't be blank")
  end
 
  scenario '[send a text to an new customer with invalid phone number]' do
    visit notifications_path
    fill_in_notification_form(first_name: "John", last_name: "Doe", phone_number: "5555555555", message: "I'm a message!") 
    click_button "Send Notification" 
    expect(page).to have_content("The 'To' number 5555555555 is not a valid phone number")
  end

  scenario '[send a text without specifying a new customer and leaving new customer flields blank]' do
    visit notifications_path
    fill_in_notification_form(message: "I'm a message!")
    click_button "Send Notification" 
    expect(page).to have_content("Please choose a customer or add a new one.")
  end
end

def fill_in_notification_form(options={})
  fill_in "First name", with: options[:first_name]
  fill_in "Last name", with: options[:last_name]
  fill_in "Phone number", with: options[:phone_number]
  fill_in "Message", with: options[:message]
end 