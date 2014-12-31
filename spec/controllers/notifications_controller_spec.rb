require 'spec_helper'
include Warden::Test::Helpers

describe NotificationsController do
  let!(:bob_business_owner) { Fabricate(:business_owner, company_name: "Bob's Burgers") }
  let!(:bob_settings) {Fabricate(:account_setting, business_owner_id: bob_business_owner.id)}
  before { sign_in bob_business_owner }
  
  describe "GET index" do
    context "[the signed in business owner has not set up the default messages]" do

      before do
        bob_business_owner.account_setting.destroy
      end
      
      it "[redirects to the settings page if the default messages are not set]" do
        get :index
        expect(response).to redirect_to account_settings_path
      end
      
      it "[it sets the flash warning if the default messages are not set]" do
        get :index
        expect(flash[:warning]).to be_present
      end
    end

    context "[the signed in business owner has set up the default messages]" do

      it "renders the index templte" do
        get :index
        expect(response).to render_template :index
      end

      it "[sets the new @notification]" do
        get :index
        expect(assigns(:notification)).to be_instance_of(Notification)
      end

      it "[sest a new @customer]" do
        get :index
        expect(assigns(:customer)).to be_instance_of(Customer)
      end


      it "[sets a new @group_notification]" do
        get :index
        expect(assigns(:group_notification)).to be_instance_of(GroupNotification)
      end


      it "[sets @groups to all the groups for the signed in business_owner]" do
        group1 = Fabricate(:group, business_owner: bob_business_owner)
        group2 = Fabricate(:group)
        get :index
        expect(assigns(:groups)).to eq([group1])
      end 

      it "[sets @queue_items to all of the current_business_owner's queue items]" do
        tom = Fabricate(:customer, business_owner: bob_business_owner)
        notification = Fabricate(:notification, customer: tom, business_owner: bob_business_owner)
        queue_item = Fabricate(:queue_item, notification: notification, business_owner: bob_business_owner)
        get :index
        expect(assigns(:queue_items)).to eq([queue_item])
      end
    end
  end


  describe "POST create" do

    context "[with valid input and clicking the 'send now' button and an existing customer]" do
      let!(:alice) { Fabricate(:customer, phone_number: '9546381523', business_owner: bob_business_owner) }

      let(:valid_post_create_request) do
        xhr :post, :create, notification: {message: "Hello Alice!", business_owner_id: bob_business_owner.id}, customer: {phone_number: alice.phone_number}
      end


      it "[renders the javascript create template]", :vcr do
        valid_post_create_request
        expect(response).to render_template :create
      end

      it "[sets a new @notification]", :vcr do
        valid_post_create_request
        expect(assigns(:notification)).to be_new_record
      end
      
      it "[saves the notification with the correct customer and message]", :vcr do
        valid_post_create_request
        expect(alice.notifications.first.message).to eq("Hello Alice!")
      end

      it "[saves the notification with the correct business_owner]", :vcr do
        valid_post_create_request
        expect(Notification.first.business_owner).to eq(bob_business_owner)
      end
      
      it "[saves the sid from twillio for the notification]", :vcr do
        valid_post_create_request
        expect(Notification.last.sid).not_to be_nil
      end

      it "[sends with the default 'send now' message if the message is left blank]", :vcr do
        xhr :post, :create, notification: {message: "", business_owner_id: bob_business_owner.id}, customer: {phone_number: alice.phone_number}
        expect(Notification.first.message_with_subject).to eq(bob_business_owner.default_message_subject + ' - ' + bob_business_owner.default_send_now_message)
      end
    end

    context "[with invalid input and clicking 'send now' and an existing customer]" do

      it "[sets a new @group_notification]" do
        xhr :post, :create, notification: {customer_id: "", message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(assigns(:group_notification)).to be_instance_of(GroupNotification)
      end

      it "[sets @groups to all the groups for the signed in business_owner]" do
        bob = Fabricate(:customer, business_owner: bob_business_owner)
        group1 = Fabricate(:group, business_owner: bob_business_owner)
        group2 = Fabricate(:group)
        xhr :post, :create, notification: {customer_id: bob.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(assigns(:groups)).to eq([group1])
      end 

      it "[sets the @notification]" do
        bob = Fabricate(:customer)
        xhr :post, :create, notification: {customer_id: bob.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(assigns(:notification)).to be_instance_of(Notification)
      end

      it "[renders the javascript create template]" do
        bob = Fabricate(:customer)
        xhr :post, :create, notification: {customer_id: bob.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(response).to render_template :create, format: :js
      end
    end

    context "[with valid input and sending the notification to a new customer]" do
      let(:valid_post_create_request) do
        xhr :post, :create, notification: {customer_id: "", message: "Hello Alice!"}, customer: Fabricate.attributes_for(:customer, first_name: "Douglas")
      end

      it "[redirects to the notifications index path]", :vcr do
        valid_post_create_request
        expect(response).to render_template :create, format: :js
      end

      it "[sets the @notification]", :vcr do
        valid_post_create_request
        expect(assigns(:notification)).to be_instance_of(Notification)
      end

      it "[creates the new customer and associates them with the signed in business_owner]", :vcr do
        valid_post_create_request
        expect(bob_business_owner.customers.first.first_name).to eq("Douglas")
      end

      it "[saves the notification with the current customer and message]", :vcr do
        valid_post_create_request
        expect(Notification.first.customer.first_name).to eq("Douglas")
        expect(Notification.first.message).to eq("Hello Alice!")
      end
      
      it "[saves the sid from twillio for the notification]", :vcr do
        xhr :post, :create, notification: {customer_id: "", message: "Hello Alice!"}, customer: {first_name: "Doug", last_name: "S", phone_number: '9546381523'
        }        
        expect(Notification.last.sid).not_to be_nil 
      end     
    end

    context "[with invalid input and a new customer]" do
      it "[renders the javascript create template with invalid customer info]" do
        xhr :post, :create, notification: {customer_id: "", message: "Hello Alice!"}, customer: {first_name: "Doug", last_name: "", phone_number: ""}
        expect(response).to render_template :create
      end

      it "[renders the javascript create template with valid customer info and a missing message]" do
        xhr :post, :create, notification: {customer_id: "", message: ""}, customer: {first_name: "Doug", last_name: "Stein", phone_number: "1234567891"}
        expect(response).to render_template :create
      end

      it "[does not save the notification]", :vcr do
        xhr :post, :create, notification: {customer_id: "", message: "Hello Alice!"}, customer: {first_name: "Doug", last_name: "", phone_number: ""}
        expect(Notification.count).to eq(0)
      end

      it "[sets the @customer with errors]" do
        xhr :post, :create, notification: {customer_id: "", message: "Hello Alice!"}, customer: {first_name: "Doug", last_name: "", phone_number: ""}
        expect(assigns(:customer).errors).not_to be_nil
      end

      # TODO: check for an invalid phone number error in the feature spec

      it "[sets the @customers for the current business_owner]" do
        alice_business_owner = Fabricate(:business_owner)
        tom = Fabricate(:customer, business_owner: bob_business_owner, phone_number: '1234567890')
        frank = Fabricate(:customer, business_owner: bob_business_owner, phone_number: '1234567891')
        amy = Fabricate(:customer, business_owner: alice_business_owner, phone_number: '1234567892')
        xhr :post, :create, notification: {customer_id: tom.id, message: ""}, customer: {first_name: "Doug", last_name: "Smith", phone_number: ""}
        expect(assigns(:customers)).to eq([tom, frank])
      end

      it "[sets @notifications to all of the current_business_owner's notifications ordered DESC by created on date]" do
        tom = Fabricate(:customer, business_owner: bob_business_owner)
        notification1 = Fabricate(:notification, customer: tom,  created_at: 1.days.ago, business_owner: bob_business_owner)
        notification2 = Fabricate(:notification, customer: tom,  business_owner: bob_business_owner)
        notification3 = Fabricate(:notification, customer: tom,  business_owner: Fabricate(:business_owner))
        xhr :post, :create, notification: {customer_id: tom.id, message: ""}, customer: {first_name: "Doug", last_name: "Smith", phone_number: ""}
        expect(assigns(:notifications)).to eq([notification2, notification1])
      end

    end

    context "[when adding to the queue]" do
      let!(:alice) { Fabricate(:customer, phone_number: '9546381523', business_owner: bob_business_owner) }
      let(:add_to_queue_request) do
        xhr :post, :create, notification: {message: "Thanks for the order!", business_owner_id: bob_business_owner.id}, customer: {phone_number: alice.phone_number}, commit: "send later"
      end

      it "[creates a new queue item]", :vcr do
        add_to_queue_request
        expect(QueueItem.count).to eq(1)
      end

      it "[associated the new notification with the queue item]", :vcr do
        add_to_queue_request
        expect(QueueItem.first.notification).to eq(Notification.first)
      end
      
      it "[associated the business_owner with the queue item]", :vcr do
        add_to_queue_request
        expect(QueueItem.first.business_owner).to eq(bob_business_owner)
      end

      it "[sets the @queue_items]", :vcr do
        add_to_queue_request
        expect(assigns(:queue_items).count).to eq(1)
      end

       it "[sends with the default 'add to queue' message if the message is left blank]", :vcr do
        Fabricate(:account_setting, business_owner: bob_business_owner)
        xhr :post, :create, notification: {message: "", business_owner_id: bob_business_owner.id}, customer: {phone_number: alice.phone_number}, commit: "send later"
        expect(Notification.first.message).to eq(bob_business_owner.default_add_to_queue_message)
      end
    end
  end

  describe "POST send_queue_item" do
    let!(:alice) { Fabricate(:customer, phone_number: '9546381523', business_owner: bob_business_owner) }
    
    it "[renders the javacript queue_item template]", :vcr do
      notification = Fabricate(:notification, customer: alice, business_owner: bob_business_owner)
      queue_item = Fabricate(:queue_item, notification: notification, business_owner: bob_business_owner)
      xhr :post, :send_queue_item, id: queue_item.id
      expect(response).to render_template :queue_items, format: :js 
    end 
    
    it "[creates a new notification associated with the customer]", :vcr do
      notification = Fabricate(:notification, customer: alice, business_owner: bob_business_owner)
      queue_item = Fabricate(:queue_item, notification: notification, business_owner: bob_business_owner)
      xhr :post, :send_queue_item, id: queue_item.id
      expect(alice.notifications.count).to eq(2) 
    end

    it "[sets the order number for the new notification from the queue item]", :vcr do
      notification = Fabricate(:notification, customer: alice, order_number: '12345',business_owner: bob_business_owner)
      queue_item = Fabricate(:queue_item, notification: notification, business_owner: bob_business_owner)
      xhr :post, :send_queue_item, id: queue_item.id
      expect(Notification.last.order_number).to eq(Notification.first.order_number)
    end

    it "[sends the new notification]", :vcr do
      notification = Fabricate(:notification, customer: alice, order_number: '12345',business_owner: bob_business_owner)
      queue_item = Fabricate(:queue_item, notification: notification, business_owner: bob_business_owner)
      xhr :post, :send_queue_item, id: queue_item.id
      expect(Notification.first.sid).not_to be_nil
    end

    it "[deletes the queue item]", :vcr do
      notification = Fabricate(:notification, customer: alice, order_number: '12345',business_owner: bob_business_owner)
      queue_item = Fabricate(:queue_item, notification: notification, business_owner: bob_business_owner)
      xhr :post, :send_queue_item, id: queue_item.id
      expect(QueueItem.count).to eq(0)
    end

    it "[sets the @success_message]", :vcr do
      notification = Fabricate(:notification, customer: alice, order_number: '12345',business_owner: bob_business_owner)
      queue_item = Fabricate(:queue_item, notification: notification, business_owner: bob_business_owner)
      xhr :post, :send_queue_item, id: queue_item.id
      expect(assigns(:success_message)).to be_present
    end

    it "[sets the @error_message if the queue item doesn't exist]" do
      xhr :post, :send_queue_item, id: 1
      expect(assigns(:error_message)).to be_present
    end

    it "[sets the @queue_items]", :vcr do
      notification = Fabricate(:notification, customer: alice, order_number: '12345',business_owner: bob_business_owner)
      notification2 = Fabricate(:notification, customer: alice, order_number: '12345',business_owner: bob_business_owner)
      queue_item = Fabricate(:queue_item, notification: notification, business_owner: bob_business_owner)
      queue_item2 = Fabricate(:queue_item, notification: notification, business_owner: bob_business_owner)
      xhr :post, :send_queue_item, id: queue_item.id
      expect(assigns(:queue_items).count).to eq(1)
    end

    it "[sends with the default 'send from queue' message ]", :vcr do
      Fabricate(:account_setting, business_owner: bob_business_owner)
      notification = Fabricate(:notification, customer: alice, order_number: '12345',business_owner: bob_business_owner)
      queue_item = Fabricate(:queue_item, notification: notification, business_owner: bob_business_owner)
      xhr :post, :send_queue_item, id: queue_item.id
      expect(assigns(:success_message)).to be_present
        expect(Notification.first.message).to eq(bob_business_owner.default_send_from_queue_message)
      end

  end
end