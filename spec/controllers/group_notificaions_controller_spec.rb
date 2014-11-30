require 'spec_helper'
include Warden::Test::Helpers

describe GroupNotificationsController   do
  let!(:bob_user) { Fabricate(:user)}
  before { sign_in bob_user}
  
  describe "POST create" do
    context "[with valid input]" do
      it "redirects to the notifications index page", :vcr do
        group = Fabricate(:group)
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        expect(response).to redirect_to notifications_path
      end

      it "creates a new group_notification", :vcr do
        tom = Fabricate(:customer, user: bob_user)
        doug = Fabricate(:customer, phone_number: '3053452021', user: bob_user)
        group = Fabricate(:group, user: bob_user)
        group.customers << [tom, doug]
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        expect(bob_user.group_notifications.count).to eq(1)

      end 

      it "creates a notifications for each customer associated with the group", :vcr do
        tom = Fabricate(:customer, user: bob_user)
        doug = Fabricate(:customer, phone_number: '3053452021', user: bob_user)
        group = Fabricate(:group, user: bob_user)
        group.customers << [tom, doug]
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        group_notification = bob_user.groups.first.group_notifications.first
        expect(group_notification.notifications.count).to eq(2)
      end 

      it "[sends a text message to each customer in the group]", :vcr do
        tom = Fabricate(:customer, user: bob_user)
        doug = Fabricate(:customer, phone_number: '3053452021', user: bob_user)
        group = Fabricate(:group, user: bob_user)
        group.customers << [tom, doug]
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        group_notification = bob_user.groups.first. group_notifications.first
        expect(group_notification.notifications.sent.count).to eq(2)
      end 

      it "sets the flash success message", :vcr do
        tom = Fabricate(:customer, user: bob_user)
        group = Fabricate(:group, user: bob_user)
        group.customers << [tom]
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        expect(flash[:success]).to be_present
      end
    end

    context "[with valid input and failed phone numbers]" do
      it "[sends the texts to the valid numbers]", :vcr do
        tom = Fabricate(:customer, user: bob_user)
        doug = Fabricate(:customer, phone_number: '5555555555', user: bob_user)
        group = Fabricate(:group, user: bob_user)
        group.customers << [tom, doug]
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        group_notification = bob_user.groups.first. group_notifications.first
        expect(group_notification.notifications.last.status).not_to eq('failed')
      end

      it "[sets the status of the failed phone numbers to 'failed']", :vcr do
        doug = Fabricate(:customer, phone_number: '5555555555', user: bob_user)
        group = Fabricate(:group, user: bob_user)
        group.customers << [doug]
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        expect(Notification.first.status).to eq('failed')
      end
    end

    context "[with invalid input]" do
      let(:tom) { Fabricate(:customer, user: bob_user) }
      let(:mike) { Fabricate(:customer, user: bob_user, phone_number: '1234567897') }
      let(:group) { Fabricate(:group, user: bob_user) }
      before { group.customers << [tom] }
      let(:invalid_post_request) do
        post :create, group_notification: {group_id: group.id, group_message: ""}
      end

      it "renders the notifications index template", :vcr do
        invalid_post_request
        expect(response).to render_template :index
      end

      it "sets the new @notification", :vcr do
        invalid_post_request
        expect(assigns(:notification)).to be_instance_of(Notification)
      end

      it "sets @customers to the signed in user's customers", :vcr do
        invalid_post_request
        expect(assigns(:customers)).to eq([tom, mike])
      end

      it "sest a new @customer", :vcr do
        invalid_post_request
        expect(assigns(:customer)).to be_instance_of(Customer)
      end

      it "sets @notifications to the signed in user's notifications", :vcr do
        notification1 = Fabricate(:notification, customer: tom, user: bob_user)
        notification2 = Fabricate(:notification, customer: tom)
        invalid_post_request
        expect(assigns(:notifications)).to eq([notification1])
      end

      it "[sets the @group_notification]", :vcr do
        invalid_post_request
        expect(assigns(:group_notification)).to be_instance_of(GroupNotification)
      end  

      it "[sets @groups to all the groups for the signed in user]", :vcr do
        group2 = Fabricate(:group)
        invalid_post_request
        expect(assigns(:groups)).to eq([group])
      end 

      it "[sets the flash error message]", :vcr do
        invalid_post_request
        expect(flash[:error]).to be_present
      end
    end 
  end
end
