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
    context "[deleting an existing customer]" do
      it "[destroys any memberships related to the customer]" do
        tom = Fabricate(:customer, business_owner: bob_business_owner) 
        beer_group = Fabricate(:group, business_owner: bob_business_owner)
        Fabricate(:membership, customer: tom, group: beer_group, current_business_owner: bob_business_owner)
        delete :destroy, id: tom.id
        expect(Membership.count).to eq(0)
      end

       it "[destroys any notifications related to the customer]" do
        tom = Fabricate(:customer, business_owner: bob_business_owner) 
        Fabricate(:notification, customer: tom, message: 'hello', business_owner: bob_business_owner)
        delete :destroy, id: tom.id
        expect(Notification.count).to eq(0)
      end

      it "[does not delete a customer not belonging to the business_owner]" do
        john_business_owner = Fabricate(:business_owner)
        tom = Fabricate(:customer, business_owner: john_business_owner) 
        delete :destroy, id: tom.id
        expect(Customer.count).to eq(1)
      end
    end

    context "[business_owner tries to delete a customer that doesn't exist]" do
      it "displays a flash error" do
        delete :destroy, id: 1
        expect(flash[:warning]).to eq("That customer does not exist.")
      end
      
      it "[renders the index template]" do
        delete :destroy, id: 1
        expect(response).to render_template(:index)
      end

      it "[sets the new @customer]" do
        delete :destroy, id: 1
        expect(assigns(:customer)).to be_instance_of(Customer)
      end 
    end
  end

end
