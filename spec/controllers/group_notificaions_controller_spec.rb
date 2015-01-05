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

  before do
    Fabricate(:account_setting, business_owner: bob_business_owner)
  end

  before { sign_in bob_business_owner }

  describe 'POST create' do
    context '[with valid input]' do
      it '[creates a new group_notification]', :vcr do
        Fabricate(:membership, customer: tom, group: group)
        group_notification_params = { group_id: group.id, group_message: 'hi' }
        xhr :post, :create, group_notification: group_notification_params
        expect(bob_business_owner.group_notifications.count).to eq(1)
      end

      it '[creates a notifications for each member of the group]', :vcr do
        Fabricate(:membership, customer: tom, group: group)
        Fabricate(:membership, customer: jane, group: group)
        group_notification_params = { group_id: group.id, group_message: 'hi' }
        xhr :post, :create, group_notification: group_notification_params
        group_notification = bob_business_owner.group_notifications.first
        expect(group_notification.notifications.count).to eq(2)
      end

      it '[sets the flash success message]', :vcr do
        Fabricate(:membership, customer: tom, group: group)
        group_notification_params = { group_id: group.id, group_message: 'hi' }
        xhr :post, :create, group_notification: group_notification_params
        expect(flash[:success]).to be_present
      end
    end

    context '[with valid input and failed phone numbers]' do
      it '[sends the texts to the valid numbers]', :vcr do
        doug = Fabricate(
                :customer,
                phone_number: '5555555555',
                business_owner: bob_business_owner
              )
        Fabricate(:membership, customer: tom, group: group)
        Fabricate(:membership, customer: doug, group: group)
        group_notification_params = { group_id: group.id, group_message: 'hi' }
        xhr :post, :create, group_notification: group_notification_params
        group_notification = bob_business_owner.group_notifications.first
        expect(group_notification.notifications.last.status).to eq('failed')
      end

      it "[sets the status of the failed phone numbers to 'failed']", :vcr do
        doug = Fabricate(:customer, phone_number: '5555555555', business_owner: bob_business_owner)
        group = Fabricate(:group, business_owner: bob_business_owner)
        group.customers << [doug]
        xhr :post, :create, group_notification: {group_id: group.id, group_message: "hello everybody"}
        expect(Notification.first.status).to eq('failed')
      end
    end

    context "[with invalid input]" do
      let(:tom) { Fabricate(:customer, business_owner: bob_business_owner) }
      let(:mike) { Fabricate(:customer, business_owner: bob_business_owner, phone_number: '1234567897') }
      let(:group) { Fabricate(:group, business_owner: bob_business_owner) }
      before { group.customers << [tom] }
      let(:invalid_post_request) do
        post :create, group_notification: {group_id: group.id, group_message: ""}
      end

      it "renders the notifications index template", :vcr do
        invalid_post_request
        expect(response).to render_template :index
      end

      it "sets the new @notification", :vcr do
        invalid_post_request
        expect(assigns(:notification)).to be_instance_of(Notification)
      end

      it "sets @customers to the signed in business_owner's customers", :vcr do
        invalid_post_request
        expect(assigns(:customers)).to eq([tom, mike])
      end

      it "sest a new @customer", :vcr do
        invalid_post_request
        expect(assigns(:customer)).to be_instance_of(Customer)
      end

      it "sets @notifications to the signed in business_owner's notifications", :vcr do
        notification1 = Fabricate(:notification, customer: tom, business_owner: bob_business_owner)
        notification2 = Fabricate(:notification, customer: tom)
        invalid_post_request
        expect(assigns(:notifications)).to eq([notification1])
      end

      it "[sets the @group_notification]", :vcr do
        invalid_post_request
        expect(assigns(:group_notification)).to be_instance_of(GroupNotification)
      end  

      it "[sets @groups to all the groups for the signed in business_owner]", :vcr do
        group2 = Fabricate(:group)
        invalid_post_request
        expect(assigns(:groups)).to eq([group])
      end 

      it "[sets the flash error message]", :vcr do
        invalid_post_request
        expect(flash[:error]).to be_present
      end
    end 
  end
end
