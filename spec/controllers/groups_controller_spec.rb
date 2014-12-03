require 'spec_helper'
include Warden::Test::Helpers

describe GroupsController do
  let!(:bob_business_owner) { Fabricate(:business_owner)}
  before { sign_in bob_business_owner}
  
  describe "GET index" do
    it "renders the index tempalte" do
      get :index
      expect(response).to render_template :index
    end
    
    it "sets the new @group" do
      get :index
      expect(assigns(:group)).to be_a_new(Group)
    end

    it "sets the @groups to the groups that belong to the signed in business_owner" do
      group1 = Fabricate(:group, business_owner: bob_business_owner)
      group2 = Fabricate(:group, business_owner: bob_business_owner) 
      get :index
      expect(assigns(:groups)).to eq([group1, group2])
    end
  end
 
  describe "POST create" do
    context "[with valid input]" do
      it "[creates a new group associated with the signed in business_owner]" do
        post :create, group: {name: "walk in customers"}
        expect(Group.first.name).to eq("walk in customers") 
      end

      it "[redirects to the groups path]" do
        post :create, group: {name: "walk in customers"}
        group = Group.first
        expect(response).to redirect_to(groups_path)
      end

      it "sets the flash success message" do
        post :create, group: {name: "walk in customers"}
        expect(flash[:success]).not_to be_nil
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

      it "sets the @groups to the groups that belong to the signed in business_owner" do
        group1 = Fabricate(:group, business_owner: bob_business_owner)
        group2 = Fabricate(:group, business_owner: bob_business_owner) 
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
      group1 = Fabricate(:group, business_owner: bob_business_owner)
      get :show, id: group1.id
      expect(assigns(:group)).to eq(group1)
    end

    it "[sets the @group_customers to all the customers that are in the group]" do
      group1 = Fabricate(:group, business_owner: bob_business_owner)
      tom = Fabricate(:customer)
      dave = Fabricate(:customer, phone_number: '1234566544')
      mike = Fabricate(:customer, phone_number: '1234566547')
      group1.customers << tom
      group1.customers << dave
      get :show, id: group1.id
      expect(assigns(:group_customers)).to eq([tom, dave])
    end
    
    it "[sets the @customers_not_in_group to the signed in business_owner's customers that are not in the group]" do
      alice_business_owner = Fabricate(:business_owner)
      group1 = Fabricate(:group, business_owner: bob_business_owner)
      tom = Fabricate(:customer, business_owner: alice_business_owner)
      dave = Fabricate(:customer, phone_number: '1234566544', business_owner: bob_business_owner)
      mike = Fabricate(:customer, phone_number: '1234566547',business_owner: bob_business_owner)
      group1.customers << dave
      get :show, id: group1.id
      expect(assigns(:customers_not_in_group)).to eq([mike])
    end
  end

  describe "PATCH update" do
    it "[renders the javascript show template]" do
      group = Fabricate(:group, business_owner: bob_business_owner)
      xhr :patch, :update, id: group.id,  group: {name: "new name"}
      expect(response).to render_template :show
    end

    context "[with valid input]" do

      it "[updates the group name]" do
        group = Fabricate(:group, business_owner: bob_business_owner)
        xhr :patch, :update, id: group.id,  group: {name: "new name"}
        expect(bob_business_owner.groups.first.name).to eq("new name")
      end 
      
      it "[sets the flash success message]" do
        group = Fabricate(:group, business_owner: bob_business_owner)
        xhr :patch, :update, id: group.id,  group: {name: "new name"}
        expect(flash[:success]).not_to be_nil
      end
    end

    context "[with invalid input]" do
      it "[sets the @group]" do
        group = Fabricate(:group, business_owner: bob_business_owner)
        xhr :patch, :update, id: group.id,  group: {name: ""}
        expect(assigns(:group)).to eq(group)
      end

      it "[renders the show template with invalid input]" do
        group = Fabricate(:group, business_owner: bob_business_owner)
        xhr :patch, :update, id: group.id,  group: {name: ""}
        expect(response).to render_template :show
      end
    end
  end

  describe "DELETE destroy" do
    it "[redirects to the groups index page]" do
      group = Fabricate(:group, business_owner: bob_business_owner )
      delete :destroy, id: group.id
      expect(response).to redirect_to groups_path
    end 

    it "[deletes the group]" do
      group = Fabricate(:group, business_owner: bob_business_owner )
      expect(Group.count).to eq(1)
      delete :destroy, id: group.id
      expect(Group.count).to eq(0)
    end

    it "[deletes all the customer groupings related to the group]" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      fun_group = Fabricate(:group, business_owner: bob_business_owner )
      CustomerGroup.create(group: fun_group, customer: tom)
      delete :destroy, id: fun_group.id
      expect(CustomerGroup.count).to eq(0)
    end

    it "does not delete any customer groupings that are not associated to the group being deleted" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      fun_group = Fabricate(:group, business_owner: bob_business_owner )
      CustomerGroup.create(group: Fabricate(:group), customer: tom)
      delete :destroy, id: fun_group.id
      expect(CustomerGroup.count).to eq(1)
    end

    it "[does not delete the group if it's not associated witht he signed in business_owner]" do
      group = Fabricate(:group, business_owner: Fabricate(:business_owner))
      delete :destroy, id: group.id
      expect(Group.count).to eq(1)
    end 

    it "[renders the index template if the group doesn't belong to the business_owner]" do
      group = Fabricate(:group, business_owner: Fabricate(:business_owner))
      delete :destroy, id: group.id
      expect(response).to render_template :index
    end

  end 

end
