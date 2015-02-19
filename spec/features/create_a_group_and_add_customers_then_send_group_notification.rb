require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!
  
  
feature "[create group and add customers then send_= notification to group]" do 
  let(:doug) { Fabricate(:business_owner)}
  background {login_as doug, scope: :business_owner, run_callbacks: false}

  scenario "adding a new group and add a customer to it" do
    visit groups_path
    fill_in 'group_name', with: 'group'
    click_button "Add Keyword"
    expect(page).to have_content('The "group" group has been created.')

    tom = Fabricate(:customer, business_owner: doug)

    click_link "group"
    expect(current_path).to eq(group_path(Group.first))

    find("a[href='/memberships?customer=#{tom.id}&group=#{Group.first.id}']").click
    expect(page).to have_xpath("//a[@id='member_#{tom.id}']")
  end

  scenario "sending a text to a group", :vcr do
    beer_group = Fabricate(:group, name: "Beer", business_owner: doug)
    tom = Fabricate(:customer, business_owner: doug)
    Fabricate(:membership, customer: tom, group: beer_group, current_business_owner: doug)
    visit notifications_path
    select beer_group.id, :from => "Choose an existing group"
    fill_in 'Group Message', with: 'Hello everybody!'
    click_button 'Send Group Notification'
    expect(page).to have_content('A text has been successfully sent to the "Beer" group.')
  end

  scenario "delete a customer from a group" do
    beer_group = Fabricate(:group, name: "Beer", business_owner: doug)
    tom = Fabricate(:customer, business_owner: doug)
    Fabricate(:membership, customer: tom, group: beer_group, current_business_owner: doug)
    visit group_path(beer_group)
    find(:xpath, "//a[@id='member_#{tom.id}']").click
    
    expect(page).not_to have_xpath("//a[@id='member_#{tom.id}']")
    expect(page).to have_xpath("a[href='/memberships?customer=#{tom.id}&group=#{beer_group.id}']")
  end

  

end
Warden.test_reset!