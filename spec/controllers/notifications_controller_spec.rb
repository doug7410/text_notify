require 'spec_helper'
include Warden::Test::Helpers

describe NotificationsController do
  let!(:bob_business_owner) { Fabricate(:business_owner) }
  before { sign_in bob_business_owner }
  
  describe "GET index" do
    it "[sets the new @notification]" do
      get :index
      expect(assigns(:notification)).to be_instance_of(Notification)
    end

    it "[sets @customers to the signed in business_owner's customers]" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      mike = Fabricate(:customer, business_owner: bob_business_owner, phone_number: '1234567897')
      get :index 
      expect(assigns(:customers)).to eq([tom, mike])
    end

    it "[sest a new @customer]" do
      get :index
      expect(assigns(:customer)).to be_instance_of(Customer)
    end

    it "[sets @notifications to all of the current_business_owner's notifications ordered DESC by created on date]" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      notification1 = Fabricate(:notification, customer: tom,  created_at: 1.days.ago, business_owner: bob_business_owner)
      notification2 = Fabricate(:notification, customer: tom,  business_owner: bob_business_owner)
      notification3 = Fabricate(:notification, customer: tom,  business_owner: Fabricate(:business_owner))
      get :index 
      expect(assigns(:notifications)).to eq([notification2, notification1])
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


  describe "POST create" do

    context "[with valid input and sending the notification to an existing customer]" do
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
    end

    context "[with invalid input and an existing customer]" do

      it "[sets the @customers for the current business_owner]" do
        alice_business_owner = Fabricate(:business_owner)
        tom = Fabricate(:customer, business_owner: bob_business_owner, phone_number: '9546381523')
        frank = Fabricate(:customer, business_owner: bob_business_owner, phone_number: '1234567891')
        amy = Fabricate(:customer, business_owner: alice_business_owner, phone_number: '1234567892')
        xhr :post, :create, notification: {customer_id: tom.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(assigns(:customers)).to eq([tom, frank])
      end

      it "[sets @notifications to all of the current_business_owner's notifications ordered DESC by created on date]" do
        tom = Fabricate(:customer, business_owner: bob_business_owner)
        notification1 = Fabricate(:notification, customer: tom,  created_at: 1.days.ago, business_owner: bob_business_owner)
        notification2 = Fabricate(:notification, customer: tom,  business_owner: bob_business_owner)
        notification3 = Fabricate(:notification, customer: tom,  business_owner: Fabricate(:business_owner))
        xhr :post, :create, notification: {customer_id: tom.id, message: ""}, customer: {first_name: "", last_name: "", phone_number: ""}
        expect(assigns(:notifications)).to eq([notification2, notification1])
      end

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

      it "[creates a new queue item]" do
        add_to_queue_request
        expect(QueueItem.count).to eq(1)
      end

      it "[associated the new notification with the queue item]" do
        add_to_queue_request
        expect(QueueItem.first.notification).to eq(Notification.first)
      end
      
      it "[associated the business_owner with the queue item]" do
        add_to_queue_request
        expect(QueueItem.first.business_owner).to eq(bob_business_owner)
      end
    end
  end

  describe "GET view" do
    
  end  

 



 
end