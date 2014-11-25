require 'spec_helper'
include Warden::Test::Helpers

describe GroupNotificationsController   do
  let!(:bob_user) { Fabricate(:user)}
  before { sign_in bob_user}
  
  describe "POST create" do
    context "with valid input", :vcr do
      it "redirects to the notifications index page" do
        group = Fabricate(:group)
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        expect(response).to redirect_to notifications_path
      end

      it "creates a new group_notification" do
        tom = Fabricate(:customer, user: bob_user)
        doug = Fabricate(:customer, phone_number: '3053452021', user: bob_user)
        group = Fabricate(:group, user: bob_user)
        group.customers << [tom, doug]
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        expect(bob_user.group_notifications.count).to eq(1)

      end 

      it "creates a notifications for each customer associated with the group" do
        tom = Fabricate(:customer, user: bob_user)
        doug = Fabricate(:customer, phone_number: '3053452021', user: bob_user)
        group = Fabricate(:group, user: bob_user)
        group.customers << [tom, doug]
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        group_notification = bob_user.groups.first.group_notifications.first
        expect(group_notification.notifications.count).to eq(2)
      end 

      it "sends a text message to each customer in the group" do
        tom = Fabricate(:customer, user: bob_user)
        doug = Fabricate(:customer, phone_number: '3053452021', user: bob_user)
        group = Fabricate(:group, user: bob_user)
        group.customers << [tom, doug]
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        group_notification = bob_user.groups.first. group_notifications.first
        expect(group_notification.notifications.sent.count).to eq(2)
      end 

      it "sets the flash success message" do
        tom = Fabricate(:customer, user: bob_user)
        group = Fabricate(:group, user: bob_user)
        group.customers << [tom]
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        expect(flash[:success]).to be_present
      end
    end

    context "with invalid input" do

    end 
  end
end
