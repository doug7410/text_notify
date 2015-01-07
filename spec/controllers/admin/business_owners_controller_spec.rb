require 'spec_helper'
include Warden::Test::Helpers

describe Admin::BusinessOwnersController do
  let!(:bob) { Fabricate(:business_owner, admin: true) }
  before { sign_in bob }

  describe "GET index" do
    let!(:tom) { Fabricate(:business_owner) }
    let!(:jim) { Fabricate(:business_owner) }
    
    it 'renders the admin/index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'gets all the @business_owners expt for the admin' do
      get :index
      expect(assigns(:business_owners).count).to eq(2)
    end
  end
end