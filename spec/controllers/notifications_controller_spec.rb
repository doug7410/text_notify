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
    let(:bob) { Fabricate(:customer, phone_number: "9546381523") }

    context "[with valid input and sending the notification]" do
      
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
      
      it "[sends the notification to the customer]"
    end

    context "[with valid input and saving the notification]"

    context "[with invalid input]" do
      it "does not save the notification" do
        post :create, notification: {customer_id: bob.id, message: ""}
        expect(Notification.count).to eq(0)
      end
      
      it "sets the @notification and renders the new template" do
        post :create, notification: {customer_id: bob.id, message: ""}
        expect(response).to render_template :new
        expect(assigns(:notification)).to be_instance_of(Notification)
      end
      
      it "[does not send the notification to the customer]"
    end
  end
end