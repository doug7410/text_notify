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

      it "[sets the flash success message]" do
        post :create, group: {name: "walk in customers"}
        expect(flash[:success]).not_to be_nil
      end

      it "[does not create the group if it allrady exist with another business owner]" do
        miami = Fabricate(:group, name: 'miami', business_owner: Fabricate(:business_owner))
        post :create, group: {name: "miami"}
        expect(Group.count).to eq(1)
      end

      it "[sets the correct flash error if the the group name has been taken]" do
        miami = Fabricate(:group, name: 'miami', business_owner: Fabricate(:business_owner))
        post :create, group: {name: "miami"}
        expect(flash[:error]).to eq("Sorry the group name 'miami' has been taken, please try a different name.")
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

    it "[sets the @members to all the customers that are in the group]" do
      group1 = Fabricate(:group, business_owner: bob_business_owner)
      dave = Fabricate(:customer, phone_number: '1234566544', business_owner: bob_business_owner)
      mike = Fabricate(:customer, phone_number: '1234566547', business_owner: bob_business_owner)
      Membership.create(customer: dave, group: group1, current_business_owner: bob_business_owner)
      Membership.create(customer: mike, group: group1, current_business_owner: bob_business_owner)
      get :show, id: group1.id
      expect(assigns(:members)).to eq(group1.memberships.all)
    end
    
    it "[sets the @customers_not_in_group to the signed in business_owner's customers that are not in the group]" do
      alice_business_owner = Fabricate(:business_owner)
      group1 = Fabricate(:group, business_owner: bob_business_owner)
      tom = Fabricate(:customer, business_owner: alice_business_owner)
      dave = Fabricate(:customer, phone_number: '1234566544', business_owner: bob_business_owner)
      mike = Fabricate(:customer, phone_number: '1234566547',business_owner: bob_business_owner)
      Membership.create(customer: dave, group: group1, current_business_owner: bob_business_owner)
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

    it "[deletes all the memberships related to the group]" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      fun_group = Fabricate(:group, business_owner: bob_business_owner )
      Fabricate(:membership, customer: tom, group: fun_group, current_business_owner: bob_business_owner)
      delete :destroy, id: fun_group.id
      expect(Membership.count).to eq(0)
    end

    it "[does not delete any Memberships that are not associated with the group being deleted]" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      fun_group = Fabricate(:group, business_owner: bob_business_owner )
      beer_group = Fabricate(:group, business_owner: bob_business_owner )
      Fabricate(:membership, customer: tom, group: beer_group, current_business_owner: bob_business_owner)
      delete :destroy, id: fun_group.id
      expect(Membership.count).to eq(1)
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
