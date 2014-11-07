require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature "a user deletes a customer" do
  scenario "a user deletes a customer", js: true do
    # bob = Fabricate(:customer)
    # sign_in_user
    user = Fabricate(:user)
    login_as(user, :scope => :user, :run_callbacks => false)
    visit customers_path
    binding.pry
    find("a[id='delete']").click
    expect(page).to have_content("Are you sure you want to delete #{bob.name}")

  end
end