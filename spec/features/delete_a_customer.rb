require 'spec_helper'

feature "a user deletes a customer" do
  scenario "a user deletes a customer" do
    bob = Fabricate(:customer, first_name: "Bob", last_name: "Jones", phone_number: "555-123-4567")
    sign_in_user
    
    visit customers_path
    expect(page).to have_content("555-123-4567")

    find("a[id='delete_#{bob.id}']").click
    expect(page).to have_content("Bob Jones has been deleted")
    expect(page).not_to have_content("555-123-4567")

  end
end