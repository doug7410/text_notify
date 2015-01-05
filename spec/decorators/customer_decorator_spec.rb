require 'spec_helper'

describe CustomerDecorator do
  describe 'display_phone_number' do
    it 'adds dashes and parenthasies to the phone number' do
      bob = Fabricate(:customer, phone_number: '5557778888')
      expect(bob.phone_number).to eq('5557778888')

      expect(bob.decorate.display_phone_number).to eq('(555)777-8888')
    end
  end

  describe 'name' do
    it 'returns the customer full_name' do
      bob = Fabricate(:customer, full_name: 'Bob Burger')
      expect(bob.decorate.name).to eq('Bob Burger')
    end

    it 'returns "generic customer" if there is no full_name' do
      bob = Fabricate(:customer, full_name: '')
      expect(bob.decorate.name).to eq('generic customer')
    end
  end
end
