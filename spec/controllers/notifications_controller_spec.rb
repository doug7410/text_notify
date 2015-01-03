require 'spec_helper'
include Warden::Test::Helpers

describe NotificationsController do
  let!(:bob_business_owner) do
    Fabricate(:business_owner, company_name: "Bob's Burgers")
  end

  let!(:bob_settings) do
    Fabricate(:account_setting, business_owner_id: bob_business_owner.id)
  end

  let(:valid_phone) { '9546381523' }

  before { sign_in bob_business_owner }

  describe 'GET index' do
    context '[the signed in business owner has not set default messages]' do
      before do
        bob_business_owner.account_setting.destroy
      end

      it '[redirects to the settings page]' do
        get :index
        expect(response).to redirect_to account_settings_path
      end

      it '[it sets the flash warning]' do
        get :index
        expect(flash[:warning]).to be_present
      end
    end

    context '[the signed in business owner has set up the default messages]' do
      it 'renders the index templte' do
        get :index
        expect(response).to render_template :index
      end

      it '[sets the new @notification] ' do
        get :index
        expect(assigns(:notification)).to be_a(Notification)
      end

      it '[sest a new @customer]' do
        get :index
        expect(assigns(:customer)).to be_a(Customer)
      end

      it '[sets a new @group_notification]' do
        get :index
        expect(assigns(:group_notification)).to be_a(GroupNotification)
      end

      it '[sets @groups to all the groups for the signed in business_owner]' do
        group = Fabricate(:group, business_owner: bob_business_owner)
        get :index
        expect(assigns(:groups)).to eq([group])
      end

      it '[sets @queue_items to all of current_business_owner queue items]' do
        tom = Fabricate(:customer, business_owner: bob_business_owner)
        notification = Fabricate(
          :notification,
          customer: tom,
          business_owner: bob_business_owner
          )
        queue_item = Fabricate(
          :queue_item,
          notification: notification,
          business_owner: bob_business_owner
          )
        get :index
        expect(assigns(:queue_items)).to eq([queue_item])
      end
    end
  end

  describe 'POST create' do
    context "[the customer's phone number is invalid]" do
      before do
        xhr :post, :create,
            notification: { customer_id: '', message: '' },
            customer:     { full_name: '', last_name: '', phone_number: '' }
      end

      it '[renders the javascript create template]' do
        expect(response).to render_template :create, format: :js
      end

      it '[sets the @notification]' do
        expect(assigns(:notification)).to be_instance_of(Notification)
      end
    end

    context '[when clicking "send now" and sending to an existing customer]' do
      let!(:alice) do
        Fabricate(
          :customer,
          phone_number: valid_phone,
          business_owner: bob_business_owner
        )
      end

      let(:valid_post_create_request) do
        xhr :post, :create,
            notification: {
              message: 'Hello Alice!',
              business_owner_id: bob_business_owner.id
            },
            customer: { phone_number: alice.phone_number }
      end

      it '[renders the javascript create template]', :vcr do
        valid_post_create_request
        expect(response).to render_template :create
      end

      it '[sets a new @notification]', :vcr do
        valid_post_create_request
        expect(assigns(:notification)).to be_new_record
      end

      it '[saves the notification with correct customer and message]', :vcr do
        valid_post_create_request
        expect(alice.notifications.first.message).to eq('Hello Alice!')
      end

      it '[saves the notification with the correct business_owner]', :vcr do
        valid_post_create_request
        expect(Notification.first.business_owner).to eq(bob_business_owner)
      end

      it '[saves the sid from twillio for the notification]', :vcr do
        valid_post_create_request
        expect(Notification.last.sid).not_to be_nil
      end

      it '[sends with the default "send now" message left blank]', :vcr do
        xhr :post, :create,
            notification: {
              message: '',
              business_owner_id: bob_business_owner.id
            },
            customer: { phone_number: alice.phone_number }
        subject = bob_business_owner.default_message_subject
        msg_body = bob_business_owner.default_send_now_message
        message =  subject + ' - ' + msg_body
        expect(Notification.first.message_with_subject).to eq(message)
      end
    end

    context '[when clicking "send now" and sending to a new customer]' do
      let(:valid_post_create_request) do
        xhr :post, :create,
            notification: { customer_id: '', message: 'Hello Alice!' },
            customer: Fabricate.attributes_for(:customer, full_name: 'Douglas')
      end

      it '[redirects to the notifications index path]', :vcr do
        valid_post_create_request
        expect(response).to render_template :create, format: :js
      end

      it '[sets the @notification]', :vcr do
        valid_post_create_request
        expect(assigns(:notification)).to be_a(Notification)
      end

      it '[creates a new customer associated with the business_owner]', :vcr do
        valid_post_create_request
        expect(bob_business_owner.customers.first.full_name).to eq('Douglas')
      end

      it '[saves the notification with the customer and message]', :vcr do
        valid_post_create_request
        expect(Notification.first.customer.full_name).to eq('Douglas')
        expect(Notification.first.message).to eq('Hello Alice!')
      end

      it '[saves the sid from twillio for the notification]', :vcr do
        valid_post_create_request
        expect(Notification.last.sid).not_to be_nil
      end
    end

    context '[when adding to txt queue and sending to an existing customer]' do
      let!(:alice) do
        Fabricate(
          :customer,
          phone_number:   valid_phone,
          business_owner: bob_business_owner
        )
      end

      let(:add_to_queue_request) do
        xhr :post, :create,
            notification: {
              message: 'Thanks for the order!',
              business_owner_id: bob_business_owner.id
            },
            customer: { phone_number: alice.phone_number },
            commit: 'send later'
      end

      it_behaves_like 'add to txt queue' do
        let(:action) { add_to_queue_request }
        let(:phone_number) { alice.phone_number }
      end
    end

    context '[when clicking send later and sending to a new customer]' do
      let(:add_to_queue_request) do
        xhr :post, :create,
            notification: {
              message: 'Thanks for the order!',
              business_owner_id: bob_business_owner.id
            },
            customer: { full_name: 'Doug S', phone_number: valid_phone },
            commit: 'send later'
      end

      it_behaves_like 'add to txt queue' do
        let(:action) { add_to_queue_request }
        let(:phone_number) { valid_phone }
      end

      it 'creates the new customer', :vcr do
        add_to_queue_request
        expect(Customer.first.full_name).to eq('Doug S')
      end
    end
  end

  describe 'POST send_queue_item' do
    let!(:alice) do
      Fabricate(
        :customer,
        phone_number: valid_phone,
        business_owner: bob_business_owner
      )
    end

    let(:notification) do
      Fabricate(
        :notification,
        customer: alice,
        order_number: '12345',
        business_owner: bob_business_owner
      )
    end

    let(:queue_item) do
      Fabricate(
        :queue_item,
        notification: notification,
        business_owner: bob_business_owner
      )
    end

    it '[renders the javacript queue_item template]', :vcr do
      xhr :post, :send_queue_item, id: queue_item.id
      expect(response).to render_template :queue_items, format: :js
    end

    it '[creates a new notification associated with the customer]', :vcr do
      xhr :post, :send_queue_item, id: queue_item.id
      expect(alice.notifications.count).to eq(2)
    end

    it '[sets the order # of the new notification from the queue item]', :vcr do
      xhr :post, :send_queue_item, id: queue_item.id
      notification1 = Notification.last
      notification2 = Notification.first
      expect(notification1.order_number).to eq(notification2.order_number)
    end

    it '[sends the new notification]', :vcr do
      xhr :post, :send_queue_item, id: queue_item.id
      expect(Notification.first.sid).not_to be_nil
    end

    it '[deletes the queue item]', :vcr do
      xhr :post, :send_queue_item, id: queue_item.id
      expect(QueueItem.count).to eq(0)
    end

    it '[sets the @success_message]', :vcr do
      xhr :post, :send_queue_item, id: queue_item.id
      expect(assigns(:success_message)).to be_present
    end

    it '[sets the @error_message if the queue item does not exist]' do
      xhr :post, :send_queue_item, id: 1
      expect(assigns(:error_message)).to be_present
    end

    it '[sets the @queue_items]', :vcr do
      notification2 = Fabricate(
                        :notification,
                        customer: alice,
                        order_number: '12345',
                        business_owner: bob_business_owner
                      )

      queue_item2 = Fabricate(
                    :queue_item,
                    notification: notification2,
                    business_owner: bob_business_owner
                  )
      xhr :post, :send_queue_item, id: queue_item.id
      expect(assigns(:queue_items)).to eq([queue_item2])
    end

    it '[sets the @success_message]' do
      xhr :post, :send_queue_item, id: queue_item.id
      expect(assigns(:success_message)).to be_present
    end

    it '[sends with the default "send from queue" message ]', :vcr do
      xhr :post, :send_queue_item, id: queue_item.id
      message = bob_business_owner.default_send_from_queue_message
      expect(Notification.first.message).to eq(message)
    end
  end
end
