require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'edit a customer' do
  let(:doug) { Fabricate(:business_owner) }

  background { login_as doug, scope: :business_owner, run_callbacks: false }

  given!(:bob) do
    Fabricate(
      :customer,
      full_name: 'Bob S',
      phone_number: '5555555555',
      business_owner: doug
    )
  end

  scenario '[a business_owner views a customer page]' do
    visit customers_path
    find("a[id='edit_#{bob.id}']").click
    expect(page).to have_content('Bob S')
  end

  scenario '[a business_owner updates a customer with valid info]' do
    visit customer_path(bob.id)

    fill_in_customer_form(full_name: 'Doug S', phone_number: '7778889999')

    click_button 'Update'

    expect(page).to have_content('Customer successfully updated')
    expect(page).to have_selector("input[value='Doug S']")
    expect(page).to have_selector("input[value='7778889999']")
  end

  scenario '[a business_owner updates a customer with invalid info]' do
    visit customer_path(bob.id)
    fill_in_customer_form(full_name: 'Bob', phone_number: '')
    click_button 'Update'

    expect(page).to have_content('Please fix the errors below.')
    expect(page).to have_content("Phone number can't be blank")
  end

  Warden.test_reset!
end

