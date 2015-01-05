require 'spec_helper'
include Warden::Test::Helpers

describe GroupsController do
  let!(:bob_business_owner) { Fabricate(:business_owner) }
  before { sign_in bob_business_owner }

  describe 'GET index' do
    it 'renders the index tempalte' do
      get :index
      expect(response).to render_template :index
    end

    it 'sets the new @group' do
      get :index
      expect(assigns(:group)).to be_a_new(Group)
    end

    it 'sets @groups to the signed in business_owner groups' do
      group1 = Fabricate(:group, business_owner: bob_business_owner)
      group2 = Fabricate(:group, business_owner: bob_business_owner)
      get :index
      expect(assigns(:groups)).to eq([group1, group2])
    end
  end

  describe 'POST create' do
    context '[with valid input]' do
      it '[creates a new group associated with the signed in business_owner]' do
        post :create, group: { name: 'miami' }
        expect(Group.first.name).to eq('miami')
      end

      it '[redirects to the groups path]' do
        post :create, group: { name: 'miami' }
        expect(response).to redirect_to(groups_path)
      end

      it '[sets the flash success message]' do
        post :create, group: { name: 'miami' }
        expect(flash[:success]).not_to be_nil
      end

      it '[does not create group if it already belongs to a business owner]' do
        Fabricate(
          :group,
          name: 'MIAMI',
          business_owner: Fabricate(:business_owner))
        post :create, group: { name: 'miami' }
        expect(Group.count).to eq(1)
      end

      it '[sets the correct flash error if the group name has been taken]' do
        tom_business_owner = Fabricate(:business_owner)
        Fabricate(:group, name: 'MIAMI', business_owner: tom_business_owner)
        post :create, group: { name: 'MIAMI' }
        message = 'Sorry the group name "MIAMI" has been taken, please try a different name.'
        expect(flash[:error]).to eq(message)
      end
    end

    context 'with invalid input' do
      let(:invalid_post_create_request) do
        post :create, group: { name: '' }
      end

      it '[does not save the group if the name is missing]' do
        invalid_post_create_request
        expect(Group.count).to eq(0)
      end

      it 'sets the @group' do
        invalid_post_create_request
        expect(assigns(:group)).to be_instance_of(Group)
      end

      it 'sets the @groups to the signed in business_owner groups' do
        group1 = Fabricate(:group, business_owner: bob_business_owner)
        group2 = Fabricate(:group, business_owner: bob_business_owner)
        invalid_post_create_request
        expect(assigns(:groups)).to eq([group1, group2])
      end

      it '[renders the index template]' do
        invalid_post_create_request
        expect(response).to render_template :index
      end
    end
  end

  describe 'GET show' do
    it 'sets the @group' do
      group1 = Fabricate(:group, business_owner: bob_business_owner)
      get :show, id: group1.id
      expect(assigns(:group)).to eq(group1)
    end

    it '[sets the @members to all the customers that are in the group]' do
      group = Fabricate(:group, business_owner: bob_business_owner)
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      Fabricate(
        :membership,
        customer: tom,
        group: group,
        current_business_owner: bob_business_owner
      )
      get :show, id: group.id
      expect(assigns(:members)).to eq(group.memberships.all)
    end

    it '[sets @customers_not_in_group to the signed in business_owner]' do
      alice_business_owner = Fabricate(:business_owner)
      group = Fabricate(:group, business_owner: bob_business_owner)
      Fabricate(:customer, business_owner: alice_business_owner)
      dave = Fabricate(
              :customer,
              phone_number: '1234566544',
              business_owner: bob_business_owner
            )
      mike = Fabricate(
              :customer,
              phone_number: '1234566547',
              business_owner: bob_business_owner
            )
      Fabricate(
        :membership,
        customer: dave,
        group: group,
        current_business_owner: bob_business_owner
      )
      get :show, id: group.id
      expect(assigns(:customers_not_in_group)).to eq([mike])
    end
  end

  describe 'PATCH update' do
    it '[renders the javascript show template]' do
      group = Fabricate(:group, business_owner: bob_business_owner)
      xhr :patch, :update, id: group.id,  group: { name: 'miami' }
      expect(response).to render_template :show
    end

    context '[with valid input]' do
      it '[updates the group name]' do
        group = Fabricate(:group, business_owner: bob_business_owner)
        xhr :patch, :update, id: group.id,  group: { name: 'miami' }
        expect(bob_business_owner.groups.first.name).to eq('miami')
      end

      it '[sets the flash success message]' do
        group = Fabricate(:group, business_owner: bob_business_owner)
        xhr :patch, :update, id: group.id,  group: { name: 'miami' }
        expect(flash[:success]).not_to be_nil
      end

      it '[sets the @error_message if the the group name has been taken]' do
        group = Fabricate(
                  :group,
                  name: 'hollywood',
                  business_owner: bob_business_owner
                )
        Fabricate(
          :group,
          name: 'miami',
          business_owner: Fabricate(:business_owner)
        )
        xhr :patch, :update, id: group.id,  group: { name: 'miami' }
        expect(assigns(:error_message)).to eq("Sorry the group name 'miami' has been taken, please try a different name.")
      end
    end

    context '[with invalid input]' do
      it '[sets the @group]' do
        group = Fabricate(:group, business_owner: bob_business_owner)
        xhr :patch, :update, id: group.id,  group: { name: '' }
        expect(assigns(:group)).to eq(group)
      end

      it '[renders the show template with invalid input]' do
        group = Fabricate(:group, business_owner: bob_business_owner)
        xhr :patch, :update, id: group.id,  group: { name: '' }
        expect(response).to render_template :show
      end
    end
  end

  describe 'DELETE destroy' do
    context '[the group belongs to the signed in business_owner]' do
      it '[redirects to the groups index page]' do
        group = Fabricate(:group, business_owner: bob_business_owner)
        delete :destroy, id: group.id
        expect(response).to redirect_to groups_path
      end

      it '[deletes the group]' do
        group = Fabricate(:group, business_owner: bob_business_owner)
        expect(Group.count).to eq(1)
        delete :destroy, id: group.id
        expect(Group.count).to eq(0)
      end

      it '[deletes all the memberships related to the group]' do
        tom = Fabricate(:customer, business_owner: bob_business_owner)
        fun_group = Fabricate(:group, business_owner: bob_business_owner)
        Fabricate(
          :membership,
          customer: tom,
          group: fun_group,
          current_business_owner: bob_business_owner
        )
        delete :destroy, id: fun_group.id
        expect(Membership.count).to eq(0)
      end

      it "[doesn't delete any Memberships not associated with the group]" do
        tom = Fabricate(:customer, business_owner: bob_business_owner)
        fun_group = Fabricate(:group, business_owner: bob_business_owner)
        beer_group = Fabricate(:group, business_owner: bob_business_owner)
        Fabricate(
          :membership,
          customer: tom,
          group: beer_group,
          current_business_owner: bob_business_owner
        )
        delete :destroy, id: fun_group.id
        expect(Membership.count).to eq(1)
      end
    end

    context '[the group does not belong to the signed in business_owner]' do
      it "[doesn't delete the group]" do
        group = Fabricate(:group, business_owner: Fabricate(:business_owner))
        delete :destroy, id: group.id
        expect(Group.count).to eq(1)
      end

      it '[renders the index template]' do
        group = Fabricate(:group, business_owner: Fabricate(:business_owner))
        delete :destroy, id: group.id
        expect(response).to render_template :index
      end
    end
  end
end

