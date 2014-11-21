require 'spec_helper'
include Warden::Test::Helpers

describe NotificationsController do
  let!(:bob_user) { Fabricate(:user) }
  before { sign_in bob_user }
  

  describe "POST create" do

    context "[with valid input]" do
      context "[all of the customers have valid phone numbers]"
    end 

    context "[with invalid input]"

  end
end 