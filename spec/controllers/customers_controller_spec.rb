require 'spec_helper'
include Warden::Test::Helpers

describe CustomersController do
  let!(:bob_user) { Fabricate(:user)}
  before { sign_in bob_user}
  
  describe "GET new" do
    it "sets the new @customer" do
      get :new
      expect(assigns(:customer)).to be_instance_of(Customer)
    end
  end

  describe "GET index" do
    it "sets the @customers that belong to the signed in user" do
      tom_user = Fabricate(:user)
      customer1 = Fabricate(:customer, user: bob_user) 
      customer2 = Fabricate(:customer, user: tom_user)
      get :index
      expect(assigns(:customers)).to eq([customer1]) 
    end

    it "sets the new @customer" do
      get :new
      expect(assigns(:customer)).to be_instance_of(Customer)
    end 
  end

  describe "POST create" do
    

    it "associates the new customer with the signed in user" do 
      bob_user = Fabricate(:user)
      post :create, customer: Fabricate.attributes_for(:customer,first_name: "Toby", phone_number: '(555)666-7788', user_id: bob_user.id)
      expect(bob_user.customers.first.first_name).to eq("Toby")
    end

    it "sets the @customers that belong to the signed in user" do
      tom_user = Fabricate(:user)
      customer1 = Fabricate(:customer, user: bob_user) 
      customer2 = Fabricate(:customer, user: tom_user)
      get :index
      expect(assigns(:customers)).to eq([customer1]) 
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

      it "sets the new @customer" do
        delete :destroy, id: 1
        expect(assigns(:customer)).to be_instance_of(Customer)
      end 
    end
  end

end
