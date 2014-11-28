require 'spec_helper'
include Warden::Test::Helpers

describe PagesController do
  let!(:bob_user) { Fabricate(:user)}
  before { sign_in bob_user}

  describe "GET front" do
    it "redirects to the dashboard if the user is signed in" do
      get :front
      expect(response).to redirect_to dashboard_path
    end
  end 

  describe "GET dashboard" do

    it "sets the @customers for the signed in user" do
      doug = Fabricate(:customer, user: bob_user)
      tom = Fabricate(:customer, user: bob_user, phone_number: '5556667777')
      get :dashboard
      expect(assigns(:customers)).to eq([doug, tom])
    end

    it "sets all the @delivered_notifications for the signed in user" do
      doug = Fabricate(:customer, user: bob_user) 
      notification1 = Fabricate(:notification, customer: doug, status: "delivered", user: bob_user)
      notification2 = Fabricate(:notification, customer: doug, status: "delivered")
      notification2 = Fabricate(:notification, customer: doug)

      get :dashboard
      expect(assigns(:delivered_notifications)).to eq([notification1])

    end
    
    it "sets all the @failed_notifications for the signed in user" do
      doug = Fabricate(:customer, user: bob_user) 
      notification1 = Fabricate(:notification, customer: doug, status: "delivered", user: bob_user)
      notification2 = Fabricate(:notification, customer: doug, status: "failed", user: bob_user)
      notification3 = Fabricate(:notification, customer: doug)

      get :dashboard
      expect(assigns(:failed_notifications)).to eq([notification2])

    end  
  end
end