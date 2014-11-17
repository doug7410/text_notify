require 'spec_helper'
include Warden::Test::Helpers

describe NotificationsController do
  let!(:bob_user) { Fabricate(:user) }
  before { sign_in bob_user }
  
  describe "GET index" do
    it "sets the new @notification" do
      get :index
      expect(assigns(:notification)).to be_instance_of(Notification)
    end

    it "sets @customers to the signed in user's customers" do
      tom = Fabricate(:customer, user: bob_user)
      mike = Fabricate(:customer, user: bob_user, phone_number: '1234567897')
      get :index 
      expect(assigns(:customers)).to eq([tom, mike])
    end

    it "sest a new @customer" do
      get :index
      expect(assigns(:customer)).to be_instance_of(Customer)
    end

    it "sets @notifications to the sent notifications" do
      tom = Fabricate(:customer, user: bob_user)
      notification1 = Fabricate(:notification, customer: tom, sid: '123456')
      notification2 = Fabricate(:notification, customer: tom, sid: '123456')
      get :index 
      expect(assigns(:notifications)).to eq([notification1, notification2])
    end
  end

  describe "GET new" do
    it "sets the new @notification" do
      get :new
      expect(assigns(:notification)).to be_instance_of(Notification)
    end

    it "sets @customers to customers associated with the signed in user" do
      tom_user = Fabricate(:user)
      customer1 = Fabricate(:customer, user: bob_user)
      customer2 = Fabricate(:customer, user: tom_user)
      get :new
      expect(assigns(:customers)).to eq([customer1])
    end
  end

  describe "POST create" do

    context "[with valid input and sending the notification]" do
      let!(:bob) { Fabricate(:customer, phone_number: '9546381523') }
      
      it "[redirects to the new_notification path]", :vcr do
        post :create, notification: {customer_id: bob.id, message: "Hello Bob!"}
        expect(response).to redirect_to new_notification_path
      end
      
      it "[saves the notification with the corrent customer and message]", :vcr do
        post :create, notification: {customer_id: bob.id, message: "Hello Bob!"}
        expect(bob.notifications.first.message).to eq("Hello Bob!")
      end

      it "[sets 'sent_date' for the notification to the current date]", :vcr do
        post :create, notification: {customer_id: bob.id, message: "Hello Bob!"}
        expect(bob.notifications.first.sent_date).to be_present
      end
      
      it "[sets the flash success message]", :vcr do
        post :create, notification: {customer_id: bob.id, message: "Hello Bob!"}
        expect(flash[:success]).to be_present
      end
      
      it "[saves the sid from twillio for the notification]", :vcr do
        post :create, notification: {customer_id: bob.id, message: "Hello Bob!"}
        expect(Notification.last.sid).not_to be_nil
      end
    end

    context "[with valid input and saving the notification]" do
      let(:bob) { Fabricate(:customer) }      

      it "[saves the notification and does not send the message]" do
        post :create, notification: {customer_id: bob.id, message: "Hello Bob!" } , do_not_send: '1'
        expect(Notification.last.sid).to be_nil
      end

      it "[sets the flash message]" do
        post :create, notification: {customer_id: bob.id, message: "Hello Bob!" } , do_not_send: '1'
        expect(Notification.count).to eq(1)
      end

      it "[redirectst to the new notification page]" do
        post :create, notification: {customer_id: bob.id, message: "Hello Bob!" } , do_not_send: '1'
        expect(response).to redirect_to new_notification_path
      end
    end

    context "[with invalid input]" do
      it "[does not save the notification with missing message]", :vcr do
        bob = Fabricate(:customer)
        post :create, notification: {customer_id: bob.id, message: ""}
        expect(Notification.count).to eq(0)
      end

      it "[sets the @customers for the current user]" do
        alice_user = Fabricate(:user)
        tom = Fabricate(:customer, user: bob_user, phone_number: '1234567890')
        frank = Fabricate(:customer, user: bob_user, phone_number: '1234567891')
        amy = Fabricate(:customer, user: alice_user, phone_number: '1234567892')
        post :create, notification: {customer_id: tom.id, message: ""}
        expect(assigns(:customers)).to eq([tom, frank])
      end

      it "[sets the @notification and renders the new template]", :vcr do
        bob = Fabricate(:customer)
        post :create, notification: {customer_id: bob.id, message: ""}
        expect(response).to render_template :new
        expect(assigns(:notification)).to be_instance_of(Notification)
      end
    end

    context "[with an invalid phone number]" do
        it "[does not save the notification]", :vcr do
          bob = Fabricate(:customer, phone_number: '5555555555')
          post :create, notification: {customer_id: bob.id, message: "Hi Bob" }
          expect(Notification.count).to eq(0)
        end

        it "[sets the flash error message for an invalid phone number]", :vcr do
          bob = Fabricate(:customer, phone_number: '5555555555')
          post :create, notification: {customer_id: bob.id, message: "test message"}
          expect(flash[:danger]).to include("phone number")
        end
        
        it "[sets the @customers for the current user]" do
          alice_user = Fabricate(:user)
          tom = Fabricate(:customer, user: bob_user, phone_number: '1234567890')
          frank = Fabricate(:customer, user: bob_user, phone_number: '1234567891')
          amy = Fabricate(:customer, user: alice_user, phone_number: '1234567892')
          post :create, notification: {customer_id: tom.id, message: ""}
          expect(assigns(:customers)).to eq([tom, frank])
        end
    end
  end

  describe "GET sent" do
    it "[sets @notifications to only the sent notifications for the signed in user]" do
      tom = Fabricate(:customer, user: bob_user)
      notification1 = Fabricate(:notification, customer_id: tom.id, sid: '123456')
      notification2 = Fabricate(:notification, customer_id: tom.id)
      get :sent
      expect(assigns(:notifications)).to eq([notification1])
    end

    it "[renders the sent_notifications page]" do
      get :sent
      expect(response).to render_template :sent
    end
  end

  describe "GET pending" do
    it "[sets @notifications to only the un-sent notifications for the signed in user]" do
      tom = Fabricate(:customer, user: bob_user)
      notification1 = Fabricate(:notification, customer_id: tom.id, sid: '123456')
      notification2 = Fabricate(:notification, customer_id: tom.id)
      get :pending
      expect(assigns(:notifications)).to eq([notification2])
    end

    it "[renders the pending template]"  do
      get :pending
      expect(response).to render_template :pending
    end
  end

  describe "POST send_notification" do 
    context "[with a valid phone number and message]" do
      it "[redirecs to the sent notifications page]", :vcr do
        tom = Fabricate(:customer, user: bob_user) 
        notification = Fabricate(:notification, customer_id: tom.id)
        post :send_notification, id: notification.id
        expect(response).to redirect_to pending_notifications_path
      end 

      it "[sends the notification]", :vcr do
        tom = Fabricate(:customer, user: bob_user)
        notification = Fabricate(:notification, customer_id: tom.id)
        post :send_notification, id: notification.id
        expect(notification.reload.sid).not_to be_nil
      end

      it "[sets the flash success message]", :vcr do 
        tom = Fabricate(:customer, user: bob_user)
        notification = Fabricate(:notification, customer_id: tom.id)
        post :send_notification, id: notification.id
        expect(flash[:success]).not_to be_nil
      end
    end

    context "[with an invalid phone number or empty message]" do
      it "[sets @notifications to only the un-sent notifications for the signed in user]" do
      tom = Fabricate(:customer, user: bob_user)
      notification1 = Fabricate(:notification, customer_id: tom.id, sid: '123456')
      notification2 = Fabricate(:notification, customer_id: tom.id)
      get :pending
      expect(assigns(:notifications)).to eq([notification2])
      end

      it "[renders the pending notifications page if the customer has an invalid phone number]", :vcr do
        tom = Fabricate(:customer, user: bob_user, phone_number: '5005550001')
        notification = Fabricate(:notification, customer_id: tom.id)
        post :send_notification, id: notification.id
        expect(response).to render_template :pending
      end

      it "sets the flash error message", :vcr do
        tom = Fabricate(:customer, user: bob_user, phone_number: '5005550001')
        notification = Fabricate(:notification, customer_id: tom.id)
        post :send_notification, id: notification.id
        expect(flash[:danger]).not_to be_nil
      end
    end
  end

  describe "DELETE destroy_pending" do
    it "[renders the pending notifications template]" do
      tom = Fabricate(:customer, user: bob_user) 
      notification = Fabricate(:notification, customer_id: tom.id)
      delete :destroy_pending, id: notification.id
      expect(response).to redirect_to pending_notifications_path
    end 

    it "[it deletes the notification and sets @notifications to only the un-sent notifications for the signed in user]" do
      tom = Fabricate(:customer, user: bob_user)
      notification1 = Fabricate(:notification, customer_id: tom.id)
      notification2 = Fabricate(:notification, customer_id: tom.id)
      delete :destroy_pending, id: notification1.id
      expect(assigns(:notifications)).to eq([notification2])
    end

    it "[sets the flash error message if the notification doesn't exist]" do
      tom = Fabricate(:customer, user: bob_user)
      delete :destroy_pending, id: 1
      expect(flash[:danger]).not_to be_nil
    end 
  end
end