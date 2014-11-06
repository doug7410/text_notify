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

end
