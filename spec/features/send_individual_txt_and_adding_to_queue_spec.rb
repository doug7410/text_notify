require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature '[add queue item and send text from queue]' do
  let(:doug) { Fabricate(:business_owner) }

  background do
    Fabricate(:account_setting, business_owner: doug)
  end

  background { login_as doug, scope: :business_owner, run_callbacks: false }

  scenario '[add a txt to the queue and sending the queue item]', :js, :vcr do
    tom = Fabricate(:customer, full_name: 'JJ Smith', business_owner: doug)
    visit notifications_path

    fill_in 'phone', with: tom.phone_number
    fill_in 'notification_order_number', with: '123456'
    click_button 'send later'
    expect(page).to have_content('A txt has been sent!')
    expect(page).to have_content('123456')
    expect(page).to have_content('JJ Smith')

    click_button 'send'
    expect(page).to have_content('the queue item has been sent')
    expect(page).not_to have_content('A txt has been sent!')
    expect(page).not_to have_content('123456')
    expect(page).not_to have_content('JJ Smith')
  end

  scenario '[leaving the phone field blank]', :js, :vcr do
    visit notifications_path
    fill_in_notification_form(full_name: '', phone_number: '')
    click_button 'send later'
    expect(page).to have_content("Phone number can't be blank")
  end
end

def fill_in_notification_form(options={})
  fill_in 'customer', with: options[:full_name]
  fill_in 'phone', with: options[:phone]
  fill_in 'notification_message', with: options[:message]
end
