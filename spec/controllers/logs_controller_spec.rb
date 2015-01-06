require 'spec_helper'

describe LogsController do
  let!(:bob_business_owner) do
    Fabricate(:business_owner, company_name: "Bob's Burgers")
  end

  let!(:bob_settings) do
    Fabricate(:account_setting, business_owner_id: bob_business_owner.id)
  end

  let(:doug) { Fabricate(:customer) }
  before { sign_in bob_business_owner }
  
  describe 'GET index' do  
    it 'gets all of the notifications for the business owner' do
      10.times do
        Fabricate(
          :notification,
          customer: doug,
          business_owner: bob_business_owner
        )
      end
      get :index
      expect(assigns(:notifications).count).to eq(10) 
    end
  end

end