require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Sent a text to a customer without adding to the queue' do
  let(:doug) { Fabricate(:business_owner) }

  background do
    Fabricate(:account_setting, business_owner: doug)
  end

  background { login_as doug, scope: :business_owner, run_callbacks: false }

  scenario '[sending to an existing customer with valid input]', :js, :vcr do
    tom = Fabricate(:customer, business_owner: doug)
    visit notifications_path

    fill_in 'phone', with: tom.phone_number
    click_button 'send now'
    expect(page).to have_content('A txt has been sent!')

    visit logs_path
    expect(page).to have_content(tom.phone_number)
  end

  scenario '[sending a text to a new customer with valid input]', :js, :vcr do
    visit notifications_path
    fill_in_notification_form(
      full_name: 'John',
      phone: '9546381523',
      message: "I'm a message!"
    )
    click_button 'send now'
    expect(page).to have_content('A txt has been sent!')

    visit logs_path
    expect(page).to have_content('John - 9546381523')
  end

  scenario '[leaving the phone field blank]', :js, :vcr do
    visit notifications_path
    fill_in_notification_form(full_name: '', phone_number: '')
    click_button 'send now'
    expect(page).to have_content("Phone number can't be blank")
  end
end

def fill_in_notification_form(options={})
  fill_in 'customer', with: options[:full_name]
  fill_in 'phone', with: options[:phone]
  fill_in 'notification_message', with: options[:message]
end
