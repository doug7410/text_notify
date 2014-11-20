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

end
