require 'spec_helper'
include Warden::Test::Helpers

describe GroupNotificationsController do
  let!(:bob_user) { Fabricate(:user)}
  before { sign_in bob_user}
  
  describe "POST create" do
    context "with valid input" do
      it "redirects to the notifications index page" do
        group = Fabricate(:group)
        post :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        expect(response).to redirect_to notifications_path
      end 
    end

    context "with invalid input" do

    end 
  end
end
