require 'spec_helper'
include Warden::Test::Helpers

describe GroupNotificationsController   do
  let!(:bob_user) { Fabricate(:user)}
  before { sign_in bob_user}
  
  describe "POST create" do
    context "[with valid input]", :vcr do
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

    context "[with valid input and failed phone numbers]" do
      
    end

    context "[with invalid input]" do
      let(:tom) { Fabricate(:customer, user: bob_user) }
      let(:mike) { Fabricate(:customer, user: bob_user, phone_number: '1234567897') }
      let(:group) { Fabricate(:group, user: bob_user) }
      before { group.customers << [tom] }
      let(:invalid_post_request) do
        post :create, group_notification: {group_id: group.id, group_message: ""}
      end

      it "renders the notifications index template" do
        invalid_post_request
        expect(response).to render_template :index
      end

      it "sets the new @notification" do
        invalid_post_request
        expect(assigns(:notification)).to be_instance_of(Notification)
      end

      it "sets @customers to the signed in user's customers" do
        invalid_post_request
        expect(assigns(:customers)).to eq([tom, mike])
      end

      it "sest a new @customer" do
        invalid_post_request
        expect(assigns(:customer)).to be_instance_of(Customer)
      end

      it "sets @notifications to the sent notifications" do
        notification1 = Fabricate(:notification, customer: tom, sid: '123456')
        notification2 = Fabricate(:notification, customer: tom, sid: '123456')
        invalid_post_request
        expect(assigns(:notifications)).to eq([notification1, notification2])
      end

      it "[sets the @group_notification]" do
        invalid_post_request
        expect(assigns(:group_notification)).to be_instance_of(GroupNotification)
      end

      it "[sets a new customer for the notification]" do
        invalid_post_request
        expect(assigns(:notification).customer).to be_instance_of(Customer)
      end  

      it "[sets @groups to all the groups for the signed in user]" do
        group2 = Fabricate(:group)
        invalid_post_request
        expect(assigns(:groups)).to eq([group])
      end 

      it "[sets an empty @group for the select dropdown]" do
        invalid_post_request
        expect(assigns(:group)).to be_instance_of(Group)
      end

      it "[sets the flash error message]" do
        invalid_post_request
        expect(flash[:error]).to be_present
      end
    end 
  end
end
