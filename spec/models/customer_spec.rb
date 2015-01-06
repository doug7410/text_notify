require 'spec_helper'

describe Customer do
  it { should validate_presence_of(:phone_number) }
  it { should validate_numericality_of(:phone_number) }
  it { should ensure_length_of(:phone_number).is_equal_to(10) }
  it do
    should validate_uniqueness_of(:phone_number).scoped_to(:business_owner_id)
  end

  describe '.format_phone_number(number)' do
    it 'strips out non-numeric characters' do
      phone_number = '555-777-8888'
      expect(Customer.format_phone_number(phone_number)).to eq('5557778888')
    end
  end

  describe '.import(import_array, business_owner_id)' do
    let(:import_array) do
      [
        {
          full_name: 'Tom',
          phone_number: '555-555-5555',
          groups: 'tacos;buritos;burgers'
        },
        {
          full_name: 'Dave',
          phone_number: '444-555-777', # invalid phone number
          groups: 'tacos'
        }
      ]
    end

    let(:bob) { Fabricate(:business_owner) }
    let(:jim) { Fabricate(:business_owner) }

    let!(:tacos) { Fabricate(:group, name: 'tacos', business_owner: bob) }
    let!(:buritos) { Fabricate(:group, name: 'buritos', business_owner: bob) }
    let!(:burgers) { Fabricate(:group, name: 'burgers', business_owner: jim) }

    it '[creates a customers for the business_owner]' do
      Customer.import(import_array, bob.id)
      expect(bob.customers.count).to eq(1)
    end

    context '[the groups belong to the business owner]' do
      it '[adds the customer to the groups]' do
        Customer.import(import_array, bob.id)
        expect(bob.customers.first.groups).to include(tacos, buritos)
      end
    end

    context '[the groups do not belong to the business owner]' do
      it '[does not add the customer to the group]' do
        Customer.import(import_array, bob.id)
        expect(bob.customers.first.groups).to_not include(burgers)
      end
    end
  end
end

