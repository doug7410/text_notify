require 'spec_helper'
include Warden::Test::Helpers

describe CustomersController do
  before { sign_in Fabricate(:user)}
  
  describe "GET new" do
    it "sets the new @customer" do
      get :new
      expect(assigns(:customer)).to be_instance_of(Customer)
    end
  end

  describe "POST create" do
    it "saves the phone number as a 10 digit number" do
      post :create, customer: Fabricate.attributes_for(:customer, phone_number: '(555)666-7788')
      expect(Customer.first.phone_number).to eq('5556667788')
    end
  end

  describe "DELETE destroy" do
    context "user tries to delete a customer that doesn't exist" do
      it "displays a flash error" do
        delete :destroy, id: 1
        expect(flash[:warning]).to eq("That customer does not exist.")
      end
      
      it "renders the index template" do
        delete :destroy, id: 1
        expect(response).to render_template(:index)
      end 
    end
  end

end
