require 'spec_helper'
include Warden::Test::Helpers

describe CustomersController do
  let!(:bob_business_owner) { Fabricate(:business_owner)}
  before { sign_in bob_business_owner}
  
  describe "GET new" do
    it "sets the new @customer" do
      get :new
      expect(assigns(:customer)).to be_instance_of(Customer)
    end
  end

  describe "GET index" do
    it "sets the @customers that belong to the signed in business_owner" do
      tom_business_owner = Fabricate(:business_owner)
      customer1 = Fabricate(:customer, business_owner: bob_business_owner) 
      customer2 = Fabricate(:customer, business_owner: tom_business_owner)
      get :index
      expect(assigns(:customers)).to eq([customer1]) 
    end

    it "sets the new @customer" do
      get :new
      expect(assigns(:customer)).to be_instance_of(Customer)
    end 
  end

  describe "POST create" do
    

    it "associates the new customer with the signed in business_owner" do 
      bob_business_owner = Fabricate(:business_owner)
      post :create, customer: Fabricate.attributes_for(:customer,first_name: "Toby", phone_number: '(555)666-7788', business_owner_id: bob_business_owner.id)
      expect(bob_business_owner.customers.first.first_name).to eq("Toby")
    end

    it "sets the @customers that belong to the signed in business_owner" do
      tom_business_owner = Fabricate(:business_owner)
      customer1 = Fabricate(:customer, business_owner: bob_business_owner) 
      customer2 = Fabricate(:customer, business_owner: tom_business_owner)
      get :index
      expect(assigns(:customers)).to eq([customer1]) 
    end
  end

  describe "DELETE destroy" do
    context "business_owner tries to delete a customer that doesn't exist" do
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
