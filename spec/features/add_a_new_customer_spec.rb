require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'add A New customer' do
  let(:doug) { Fabricate(:business_owner) }
  background { login_as doug, scope: :business_owner, run_callbacks: false }

  scenario '[a business_owner adds a new customer with valid info]' do
    visit customers_path
    fill_in_customer_form(
      full_name: 'Freddy',
      phone_number: '5551234567'
    )
    click_button 'Add'

    expect(page).to have_content('Freddy - 5551234567 has been added')
    expect(current_path).to eq(customers_path)
  end

  scenario '[a business_owner adds a new customer with invalid info]' do
    visit customers_path
    fill_in_customer_form(full_name: 'Freddy')
    click_button 'Add'

    expect(page).to have_content('Please fix the errors below.')
    expect(page).to have_content("Phone number can't be blank")
  end

  Warden.test_reset!
end
