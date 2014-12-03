require 'spec_helper'
include Warden::Test::Helpers

describe MembershipsController do
  let!(:bob_business_owner) { Fabricate(:business_owner)}
  before { sign_in bob_business_owner}

  describe "POST create" do
    it "redirects to the group page" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      beer_group = Fabricate(:group, business_owner: bob_business_owner)
      post :create, group: beer_group, customer: tom
      expect(response).to redirect_to beer_group
    end 

    it "[creates a new membership between the customer and the goup]" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      beer_group = Fabricate(:group, business_owner: bob_business_owner)
      post :create, group: beer_group.id, customer: tom.id
      expect(tom.groups.first).to eq(beer_group)  
    end

    it "[allows a customer to be added to 2 different groups]" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      beer_group = Fabricate(:group, business_owner: bob_business_owner)
      wine_group = Fabricate(:group, business_owner: bob_business_owner)
      post :create, group: beer_group.id, customer: tom.id
      post :create, group: wine_group.id, customer: tom.id
      expect(Membership.count).to eq(2)
    end

    it "[does not create the membership if the group or the customer does not belong to the signed in business_owner]" do
      mike_business_owner = Fabricate(:business_owner)
      tom = Fabricate(:customer, business_owner: mike_business_owner)
      beer_group = Fabricate(:group, business_owner: bob_business_owner)
      post :create, group: beer_group.id, customer: tom.id
      expect(Membership.count).to eq(0)

      tom = Fabricate(:customer, business_owner: bob_business_owner)
      beer_group = Fabricate(:group, business_owner: mike_business_owner)
      post :create, group: beer_group.id, customer: tom.id
      expect(Membership.count).to eq(0)
    end

    it "[does not add the customer to the group if they are allready in that group]" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      beer_group = Fabricate(:group, business_owner: bob_business_owner)
      post :create, group: beer_group.id, customer: tom.id
      expect(Membership.count).to eq(1)
      post :create, group: beer_group.id, customer: tom.id
      expect(Membership.count).to eq(1)
    end

    it "[sets the flash error message if the membership can't be created]" do
      mike_business_owner = Fabricate(:business_owner)
      tom = Fabricate(:customer, business_owner: mike_business_owner)
      beer_group = Fabricate(:group, business_owner: bob_business_owner)
      post :create, group: beer_group.id, customer: tom.id
      expect(flash[:error]).not_to be_nil
    end
  end
 
  describe "DELETE destroy" do
    it "redirects to the group page" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      beer_group = Fabricate(:group, business_owner: bob_business_owner)
      delete :destroy, group: beer_group, customer: tom
      expect(response).to redirect_to beer_group
    end 

    # it "[creates a new membership between the customer and the goup]" do
    #   tom = Fabricate(:customer, business_owner: bob_business_owner)
    #   beer_group = Fabricate(:group, business_owner: bob_business_owner)
    #   post :create, group: beer_group.id, customer: tom.id
    #   expect(tom.groups.first).to eq(beer_group)  
    # end

    # it "[allows a customer to be added to 2 different groups]" do
    #   tom = Fabricate(:customer, business_owner: bob_business_owner)
    #   beer_group = Fabricate(:group, business_owner: bob_business_owner)
    #   wine_group = Fabricate(:group, business_owner: bob_business_owner)
    #   post :create, group: beer_group.id, customer: tom.id
    #   post :create, group: wine_group.id, customer: tom.id
    #   expect(Membership.count).to eq(2)
    # end

    # it "[does not create the membership if the group or the customer does not belong to the signed in business_owner]" do
    #   mike_business_owner = Fabricate(:business_owner)
    #   tom = Fabricate(:customer, business_owner: mike_business_owner)
    #   beer_group = Fabricate(:group, business_owner: bob_business_owner)
    #   post :create, group: beer_group.id, customer: tom.id
    #   expect(Membership.count).to eq(0)

    #   tom = Fabricate(:customer, business_owner: bob_business_owner)
    #   beer_group = Fabricate(:group, business_owner: mike_business_owner)
    #   post :create, group: beer_group.id, customer: tom.id
    #   expect(Membership.count).to eq(0)
    # end

    # it "[does not add the customer to the group if they are allready in that group]" do
    #   tom = Fabricate(:customer, business_owner: bob_business_owner)
    #   beer_group = Fabricate(:group, business_owner: bob_business_owner)
    #   post :create, group: beer_group.id, customer: tom.id
    #   expect(Membership.count).to eq(1)
    #   post :create, group: beer_group.id, customer: tom.id
    #   expect(Membership.count).to eq(1)
    # end

    # it "[sets the flash error message if the membership can't be created]" do
    #   mike_business_owner = Fabricate(:business_owner)
    #   tom = Fabricate(:customer, business_owner: mike_business_owner)
    #   beer_group = Fabricate(:group, business_owner: bob_business_owner)
    #   post :create, group: beer_group.id, customer: tom.id
    #   expect(flash[:error]).not_to be_nil
    # end
  end
end