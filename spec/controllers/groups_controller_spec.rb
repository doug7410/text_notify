require 'spec_helper'
include Warden::Test::Helpers

describe GroupsController do
  let!(:bob_user) { Fabricate(:user)}
  before { sign_in bob_user}
  
  describe "GET index" do
    it "renders the index tempalte" do
      get :index
      expect(response).to render_template :index
    end
    
    it "sets the new @group" do
      get :index
      expect(assigns(:group)).to be_a_new(Group)
    end

    it "sets the @groups to the groups that belong to the signed in user" do
      group1 = Fabricate(:group, user: bob_user)
      group2 = Fabricate(:group, user: bob_user) 
      get :index
      expect(assigns(:groups)).to eq([group1, group2])
    end
  end
 
  describe "POST create" do
    context "[with valid input]" do
      it "[creates a new group associated with the signed in user]" do
        post :create, group: {name: "walk in customers"}
        expect(Group.first.name).to eq("walk in customers") 
      end

      it "[redirects to the groups page]" do
        post :create, group: {name: "walk in customers"}
        expect(response).to redirect_to(groups_path)
      end
    end 

    context "with invalid input" do
      it "[does not save the group if the name is missing]" do
        post :create, group: {name: ""}
        expect(Group.count).to eq(0) 
      end

      it "sets the @group" do
        post :create, group: {name: ""}
        expect(assigns(:group)).to be_instance_of(Group)
      end

      it "sets the @groups to the groups that belong to the signed in user" do
        group1 = Fabricate(:group, user: bob_user)
        group2 = Fabricate(:group, user: bob_user) 
        post :create, group: {name: ""}
        expect(assigns(:groups)).to eq([group1, group2])
      end  

      it "[renders the index template]" do
        post :create, group: {name: ""}
        expect(response).to render_template :index
      end
    end
  end

  

  describe "GET show" do
    it "sets the @group" do
      group1 = Fabricate(:group, user: bob_user)
      get :show, id: group1.id
      expect(assigns(:group)).to eq(group1)
    end

    it "[sets the @group_customers to all the customers that are in the group]" do
      group1 = Fabricate(:group, user: bob_user)
      tom = Fabricate(:customer)
      dave = Fabricate(:customer, phone_number: '1234566544')
      mike = Fabricate(:customer, phone_number: '1234566547')
      group1.customers << tom
      group1.customers << dave
      get :show, id: group1.id
      expect(assigns(:group_customers)).to eq([tom, dave])
    end
    
    it "[sets the @customers_not_in_group to the customers that are not in the group]" do
      group1 = Fabricate(:group, user: bob_user)
      tom = Fabricate(:customer)
      dave = Fabricate(:customer, phone_number: '1234566544')
      mike = Fabricate(:customer, phone_number: '1234566547')
      group1.customers << tom
      group1.customers << dave
      get :show, id: group1.id
      expect(assigns(:customers_not_in_group)).to eq([mike])
    end
  end

  describe "PATCH update" do
    context "[with valid input]" do
      it "[redirects to the show page]" do
        group = Fabricate(:group, user: bob_user)
        patch :update, id: group.id,  group: {name: "new name"}
        expect(response).to redirect_to group
      end

      it "[updates the group name]" do
        group = Fabricate(:group, user: bob_user)
        patch :update, id: group.id,  group: {name: "new name"}
        expect(bob_user.groups.first.name).to eq("new name")
      end 
      
      it "[sets the flash success message]" do
        group = Fabricate(:group, user: bob_user)
        patch :update, id: group.id,  group: {name: "new name"}
        expect(flash[:success]).not_to be_nil
      end
    end

    context "[with invalid input]" do
      it "[sets the @group_customers to all the customers that are in the group]" do
        group = Fabricate(:group, user: bob_user)
        tom = Fabricate(:customer)
        dave = Fabricate(:customer, phone_number: '1234566544')
        mike = Fabricate(:customer, phone_number: '1234566547')
        group.customers << tom
        group.customers << dave
        patch :update, id: group.id,  group: {name: ""}
        expect(assigns(:group_customers)).to eq([tom, dave])
      end
      
      it "[sets the @customers_not_in_group to the customers that are not in the group]" do
        group = Fabricate(:group, user: bob_user)
        tom = Fabricate(:customer)
        dave = Fabricate(:customer, phone_number: '1234566544')
        mike = Fabricate(:customer, phone_number: '1234566547')
        group.customers << tom
        group.customers << dave
        patch :update, id: group.id,  group: {name: ""}
        expect(assigns(:customers_not_in_group)).to eq([mike])
      end

      it "[sets the @group]" do
        group = Fabricate(:group, user: bob_user)
        patch :update, id: group.id,  group: {name: ""}
        expect(assigns(:group)).to eq(group)
      end

      it "[renders the show template with invalid input]" do
        group = Fabricate(:group, user: bob_user)
        patch :update, id: group.id,  group: {name: ""}
        expect(response).to render_template :show
      end
    end
  end

  describe "POST add_customer" do
    it "[redirect_to the show page]" do
      group = Fabricate(:group, user: bob_user)
      dave = Fabricate(:customer)
      post :add_customer, id: group.id, customer_id: dave.id
      expect(response).to redirect_to group_path(group)
    end

    it "[associates the customer with the group]" do
      group = Fabricate(:group, user: bob_user)
      dave = Fabricate(:customer)
      post :add_customer, id: group.id, customer_id: dave.id
      expect(group.customers.first).to eq(dave)
    end

    it "[sets the @customers_not_in_group to the customers that are not in the group]" do
      group = Fabricate(:group, user: bob_user)
      tom = Fabricate(:customer)
      dave = Fabricate(:customer, phone_number: '1234566544')
      mike = Fabricate(:customer, phone_number: '1234566547')
      post :add_customer, id: group.id, customer_id: tom.id
      expect(assigns(:customers_not_in_group)).to eq([dave, mike])
    end 

    it "[sets the @group_customers to all the customers that are in the group]" do
      group = Fabricate(:group, user: bob_user)
      tom = Fabricate(:customer)
      dave = Fabricate(:customer, phone_number: '1234566544')
      mike = Fabricate(:customer, phone_number: '1234566547')
      post :add_customer, id: group.id, customer_id: tom.id
      expect(assigns(:group_customers)).to eq([tom])
    end

    it "[sets the @group]" do
      group = Fabricate(:group, user: bob_user)
      tom = Fabricate(:customer)
      post :add_customer, id: group.id, customer_id: tom.id
      expect(assigns(:group)).to eq(group)
    end 
  end

  describe "POST remove_customer" do
    it "[redirect_to the show page]" do
      group = Fabricate(:group, user: bob_user)
      dave = Fabricate(:customer)
      group.customers << dave
      post :remove_customer, id: group.id, customer_id: dave.id
      expect(response).to redirect_to group_path(group)
    end 

    it "[deletes the customer group]" do
      group = Fabricate(:group, user: bob_user)
      dave = Fabricate(:customer)
      group.customers << dave
      expect(group.customers.first).to eq(dave)
      post :remove_customer, id: group.id, customer_id: dave.id
      expect(group.customers.count).to eq(0)
    end

    it "[sets the @customers_not_in_group to the customers that are not in the group]" do
      group = Fabricate(:group, user: bob_user)
      tom = Fabricate(:customer)
      dave = Fabricate(:customer, phone_number: '1234566544')
      mike = Fabricate(:customer, phone_number: '1234566547')
      group.customers << dave
      expect(group.customers.first).to eq(dave)
      post :remove_customer, id: group.id, customer_id: dave.id
      expect(assigns(:customers_not_in_group)).to eq([tom, dave, mike])
    end 

    it "[sets the @group_customers to all the customers that are in the group]" do
      group = Fabricate(:group, user: bob_user)
      tom = Fabricate(:customer)
      dave = Fabricate(:customer, phone_number: '1234566544')
      mike = Fabricate(:customer, phone_number: '1234566547')
      group.customers << tom
      group.customers << dave
      group.customers << mike
      expect(group.customers.all).to eq([tom, dave, mike])
      post :remove_customer, id: group.id, customer_id: tom.id
      expect(assigns(:group_customers)).to eq([dave, mike])
    end

    it "[sets the @group]" do
      group = Fabricate(:group, user: bob_user)
      tom = Fabricate(:customer)
      group.customers << tom
      post :remove_customer, id: group.id, customer_id: tom.id
      expect(assigns(:group)).to eq(group)
    end 
  end
end
