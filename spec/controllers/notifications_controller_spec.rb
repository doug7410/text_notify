require 'spec_helper'
include Warden::Test::Helpers

describe NotificationsController do
  let!(:bob_user) { Fabricate(:user) }
  before { sign_in bob_user }
  
  describe "GET index" do
    it "[sets the new @notification]" do
      get :index
      expect(assigns(:notification)).to be_instance_of(Notification)
    end

    it "[sets @customers to the signed in user's customers]" do
      tom = Fabricate(:customer, user: bob_user)
      mike = Fabricate(:customer, user: bob_user, phone_number: '1234567897')
      get :index 
      expect(assigns(:customers)).to eq([tom, mike])
    end

    it "[sest a new @customer]" do
      get :index
      expect(assigns(:customer)).to be_instance_of(Customer)
    end

    it "[sets @notifications to all of the current_user's notifications ordered DESC by created on date]" do
      tom = Fabricate(:customer, user: bob_user)
      notification1 = Fabricate(:notification, customer: tom,  created_at: 1.days.ago, user: bob_user)
      notification2 = Fabricate(:notification, customer: tom,  user: bob_user)
      notification3 = Fabricate(:notification, customer: tom,  user: Fabricate(:user))
      get :index 
      expect(assigns(:notifications)).to eq([notification2, notification1])
    end 

    it "[sets a new @group_notification]" do
      get :index
      expect(assigns(:group_notification)).to be_instance_of(GroupNotification)
    end


    it "[sets @groups to all the groups for the signed in user]" do
      group1 = Fabricate(:group, user: bob_user)
      group2 = Fabricate(:group)
      get :index
      expect(assigns(:groups)).to eq([group1])
    end 
  end


  describe "POST create" do

    context "[with valid input and sending the notification to an existing customer]" do
      let(:alice) { Fabricate(:customer, phone_number: '9546381523', user: bob_user) }

      let(:valid_post_create_request) do
        post :create, notification: {customer_id: alice.id, message: "Hello Alice!", user_id: bob_user.id}, customer: {first_name: "", last_name: "", phone_number: ""}
      end
      
      it "[redirects to the notifications index path]", :vcr do
        valid_post_create_request
        expect(response).to redirect_to notifications_path
      end
      
      it "[saves the notification with the correct customer and message]", :vcr do
        valid_post_create_request
        expect(alice.notifications.first.message).to eq("Hello Alice!")
      end

      it "[saves the notification with the correct user]", :vcr do
        valid_post_create_request
        expect(Notification.first.user).to eq(bob_user)
      end

      it "[sets the flash success message]", :vcr do
        valid_post_create_request
        expect(flash[:success]).to be_present
      end
      
      it "[saves the sid from twillio for the notification]", :vcr do
        valid_post_create_request
        expect(Notification.last.sid).not_to be_nil
      end
    end

    context "[with valid input and sending the notification to a new customer]" do
      let(:valid_post_create_request) do
        post :create, notification: {customer_id: "", message: "Hello Alice!"}, customer: Fabricate.attributes_for(:customer, first_name: "Douglas")
      end

      it "[redirects to the notifications index path]", :vcr do
        valid_post_create_request
        expect(response).to redirect_to notifications_path
      end

      it "[creates the new customer and associates them with the signed in user]", :vcr do
        valid_post_create_request
        expect(bob_user.customers.first.first_name).to eq("Douglas")
      end

      it "[saves the notification with the current customer and message]", :vcr do
        valid_post_create_request
        expect(Notification.first.customer.first_name).to eq("Douglas")
        expect(Notification.first.message).to eq("Hello Alice!")
      end
      
      it "[sets the flash success message]", :vcr do
        valid_post_create_request
        expect(flash[:success]).to be_present
      end
      
      it "[saves the sid from twillio for the notification]", :vcr do
        valid_post_create_request
        expect(Notification.last.sid).not_to be_nil
      end
    end


    context "[with invalid input and an existing customer]" do

      it "[does not save the notification with missing message]", :vcr do
        bob = Fabricate(:customer)
        post :create, notification: {customer_id: bob.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(Notification.count).to eq(0)
      end

      it "[sets the @customers for the current user]" do
        alice_user = Fabricate(:user)
        tom = Fabricate(:customer, user: bob_user, phone_number: '9546381523')
        frank = Fabricate(:customer, user: bob_user, phone_number: '1234567891')
        amy = Fabricate(:customer, user: alice_user, phone_number: '1234567892')
        post :create, notification: {customer_id: tom.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(assigns(:customers)).to eq([tom, frank])
      end

      it "[sets @notifications to all of the current_user's notifications ordered DESC by created on date]" do
        tom = Fabricate(:customer, user: bob_user)
        notification1 = Fabricate(:notification, customer: tom,  created_at: 1.days.ago, user: bob_user)
        notification2 = Fabricate(:notification, customer: tom,  user: bob_user)
        notification3 = Fabricate(:notification, customer: tom,  user: Fabricate(:user))
        post :create, notification: {customer_id: tom.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(assigns(:notifications)).to eq([notification2, notification1])
      end

      it "[sets a new @group_notification]" do
        post :create, notification: {customer_id: "", message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(assigns(:group_notification)).to be_instance_of(GroupNotification)
      end

      it "[sets @groups to all the groups for the signed in user]" do
        bob = Fabricate(:customer, user: bob_user)
        group1 = Fabricate(:group, user: bob_user)
        group2 = Fabricate(:group)
        post :create, notification: {customer_id: bob.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(assigns(:groups)).to eq([group1])
      end 


      it "[sets the @notification and renders the index template]" do
        bob = Fabricate(:customer)
        post :create, notification: {customer_id: bob.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(response).to render_template :index
        expect(assigns(:notification)).to be_instance_of(Notification)
      end

      it "[sets the flash error message]" do
        bob = Fabricate(:customer)
        post :create, notification: {customer_id: bob.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(response).to render_template :index
        expect(flash[:error]).to be_present
      end
    end

    context "[with invalid input and a new customer]" do
        it "[renders the index template with invalid customer info]" do
          post :create, notification: {customer_id: "", message: "Hello Alice!"}, customer: {first_name: "Doug", last_name: "", phone_number: ""}
          expect(response).to render_template :index
        end

        it "[renders the index template with valid customer info and a missing message]" do
          post :create, notification: {customer_id: "", message: ""}, customer: {first_name: "Doug", last_name: "Stein", phone_number: "1234567891"}
          expect(response).to render_template :index
        end

        it "[does not save the notification]", :vcr do
          post :create, notification: {customer_id: "", message: "Hello Alice!"}, customer: {first_name: "Doug", last_name: "", phone_number: ""}
          expect(Notification.count).to eq(0)
        end

        it "[sets the @customer with errors]" do
          post :create, notification: {customer_id: "", message: "Hello Alice!"}, customer: {first_name: "Doug", last_name: "", phone_number: ""}
          expect(assigns(:customer).errors).not_to be_nil
        end

        # TODO: check for an invalid phone number error in the feature spec

        it "[sets the @customers for the current user]" do
          alice_user = Fabricate(:user)
          tom = Fabricate(:customer, user: bob_user, phone_number: '1234567890')
          frank = Fabricate(:customer, user: bob_user, phone_number: '1234567891')
          amy = Fabricate(:customer, user: alice_user, phone_number: '1234567892')
          post :create, notification: {customer_id: tom.id, message: ""}, customer: {first_name: "Doug", last_name: "Smith", phone_number: ""}
          expect(assigns(:customers)).to eq([tom, frank])
        end

        it "[sets @notifications to all of the current_user's notifications ordered DESC by created on date]" do
          tom = Fabricate(:customer, user: bob_user)
          notification1 = Fabricate(:notification, customer: tom,  created_at: 1.days.ago, user: bob_user)
          notification2 = Fabricate(:notification, customer: tom,  user: bob_user)
          notification3 = Fabricate(:notification, customer: tom,  user: Fabricate(:user))
          post :create, notification: {customer_id: tom.id, message: ""}, customer: {first_name: "Doug", last_name: "Smith", phone_number: ""}
          expect(assigns(:notifications)).to eq([notification2, notification1])
        end

    end
  end

  

 



 
end