require 'spec_helper'
include Warden::Test::Helpers

describe CustomersController do
  let!(:bob_business_owner) { Fabricate(:business_owner) }
  before { sign_in bob_business_owner }

  describe 'GET index' do
    it 'sets the @customers for the signed in business_owner' do
      tom_business_owner = Fabricate(:business_owner)
      customer1 = Fabricate(:customer, business_owner: bob_business_owner)
      Fabricate(:customer, business_owner: tom_business_owner)
      get :index
      expect(assigns(:customers)).to eq([customer1])
    end

    it 'sets a new @customer' do
      get :index
      expect(assigns(:customer)).to be_instance_of(Customer)
    end
  end

  describe 'POST create' do
    it 'associates the customer with the signed in business_owner' do
      customer_params = { full_name: 'Toby', phone_number: '(555)666-7788' }
      post :create, customer: customer_params
      expect(bob_business_owner.customers.first.full_name).to eq('Toby')
    end

    it 'sets the @customers that belong to the signed in business_owner' do
      tom_business_owner = Fabricate(:business_owner)
      customer1 = Fabricate(:customer, business_owner: bob_business_owner)
      Fabricate(:customer, business_owner: tom_business_owner)
      get :index
      expect(assigns(:customers)).to eq([customer1])
    end
  end
end

