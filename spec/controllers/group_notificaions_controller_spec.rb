require 'spec_helper'
include Warden::Test::Helpers

describe GroupNotificationsController   do
  let!(:bob_business_owner) { Fabricate(:business_owner) }
  let(:tom) { Fabricate(:customer, business_owner: bob_business_owner) }

  let(:jane) do
    Fabricate(
      :customer,
      phone_number: '3053452021',
      business_owner: bob_business_owner
    )
  end

  let(:group) { Fabricate(:group, business_owner: bob_business_owner) }

  let(:valid_post_create_request) do
    group_notification_params = { group_id: group.id, group_message: 'hi' }
    xhr :post, :create, group_notification: group_notification_params
  end

  before do
    Fabricate(:account_setting, business_owner: bob_business_owner)
  end

  before { sign_in bob_business_owner }

  describe 'POST create' do
    context '[with valid input]' do
      it '[creates a new group_notification]', :vcr do
        Fabricate(:membership, customer: tom, group: group)
        valid_post_create_request
        expect(bob_business_owner.group_notifications.count).to eq(1)
      end

      it '[creates a notifications for each member of the group]', :vcr do
        Fabricate(:membership, customer: tom, group: group)
        Fabricate(:membership, customer: jane, group: group)
        valid_post_create_request
        group_notification = bob_business_owner.group_notifications.first
        expect(group_notification.notifications.count).to eq(2)
      end

      it '[sets the flash success message]', :vcr do
        Fabricate(:membership, customer: tom, group: group)
        valid_post_create_request
        expect(flash[:success]).to be_present
      end

      it ["sets @groups to the signed in business_owner's groups"], :vcr do
        valid_post_create_request
        expect(assigns(:groups)).to eq([group])
      end
    end

    context '[with valid input and failed phone numbers]' do
      it '[creates a notification for each member of the group]', :vcr do
        doug = Fabricate(
          :customer,
          phone_number: '5555555555',
          business_owner: bob_business_owner
        )
        group = Fabricate(:group, business_owner: bob_business_owner)
        Fabricate(:membership, customer: doug, group: group)
        Fabricate(:membership, customer: tom, group: group)
        params = { group_id: group.id, group_message: 'hello everybody' }
        xhr :post, :create, group_notification: params
        expect(Notification.count).to eq(2)
      end
    end

    context '[with invalid input]' do
      before { group.customers << [tom] }
      let(:invalid_post_request) do
        params = { group_id: group.id, group_message: '' }
        xhr :post, :create, group_notification: params
      end

      it '[renders the javascript group template]', :vcr do
        invalid_post_request
        expect(response).to render_template :group, type: :js
      end

      it ["sets @groups to the signed in business_owner's groups"], :vcr do
        invalid_post_request
        expect(assigns(:groups)).to eq([group])
      end

      it '[sets the @group_notification]', :vcr do
        invalid_post_request
        expect(assigns(:group_notification)).to be_a(GroupNotification)
      end

      it '[sets the flash error message]', :vcr do
        invalid_post_request
        expect(flash[:error]).to be_present
      end
    end
  end
end
