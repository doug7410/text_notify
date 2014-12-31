require 'spec_helper'
include Warden::Test::Helpers

describe PagesController do
  let!(:bob_business_owner) { Fabricate(:business_owner)}
  before { sign_in bob_business_owner}

  describe "GET front" do
    it "redirects to the dashboard if the business_owner is signed in" do
      get :front
      expect(response).to redirect_to dashboard_path
    end
  end 

  describe "GET dashboard" do

    it "sets the @customers_count for the signed in business_owner" do
      doug = Fabricate(:customer, business_owner: bob_business_owner)
      tom = Fabricate(:customer, business_owner: bob_business_owner, phone_number: '5556667777')
      get :dashboard
      expect(assigns(:customers_count)).to eq(2)
    end

    it "sets all the @delivered_notifications_count for the signed in business_owner" do
      doug = Fabricate(:customer, business_owner: bob_business_owner) 
      notification1 = Fabricate(:notification, customer: doug, status: "delivered", business_owner: bob_business_owner)
      notification2 = Fabricate(:notification, customer: doug, status: "delivered")
      notification2 = Fabricate(:notification, customer: doug)

      get :dashboard
      expect(assigns(:delivered_notifications_count)).to eq(1)

    end
    
    it "sets all the @failed_notifications_count for the signed in business_owner" do
      doug = Fabricate(:customer, business_owner: bob_business_owner) 
      notification1 = Fabricate(:notification, customer: doug, status: "delivered", business_owner: bob_business_owner)
      notification2 = Fabricate(:notification, customer: doug, status: "failed", business_owner: bob_business_owner)
      notification3 = Fabricate(:notification, customer: doug)

      get :dashboard
      expect(assigns(:failed_notifications_count)).to eq(1)

    end  
  end
end