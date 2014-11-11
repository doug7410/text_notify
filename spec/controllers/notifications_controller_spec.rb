require 'spec_helper'
include Warden::Test::Helpers

describe NotificationsController do
  before { sign_in Fabricate(:user)}
  
  describe "GET new" do
    it "sets the new @notification" do
      get :new
      expect(assigns(:notification)).to be_instance_of(Notification)
    end
  end

  describe "POST create" do

    context "[with valid input and sending the notification]" do
      let(:bob) { Fabricate(:customer, phone_number: '9546381523') }
      
      it "[redirects to the new_notification path]", :vcr do
        post :create, notification: {customer_id: bob.id, message: "Hello Bob!"}
        expect(response).to redirect_to new_notification_path
      end
      
      it "[saves the notification with the corrent customer and message]", :vcr do
        post :create, notification: {customer_id: bob.id, message: "Hello Bob!"}
        expect(bob.notifications.first.message).to eq("Hello Bob!")
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

      it "[does not save the notification with invalid phone number]", :vcr do
        bob = Fabricate(:customer, phone_number: '5555555555')
        post :create, notification: {customer_id: bob.id, message: "Hi Bob" }
        expect(Notification.count).to eq(0)
      end
      
      it "[sets the flash error message for an invalid phone number]", :vcr do
        bob = Fabricate(:customer, phone_number: '5555555555')
        post :create, notification: {customer_id: bob.id, message: "test message"}
        expect(flash[:danger]).to include("phone number")
      end

      it "[sets the @notification and renders the new template]", :vcr do
        bob = Fabricate(:customer)
        post :create, notification: {customer_id: bob.id, message: ""}
        expect(response).to render_template :new
        expect(assigns(:notification)).to be_instance_of(Notification)
      end
    end
  end
end