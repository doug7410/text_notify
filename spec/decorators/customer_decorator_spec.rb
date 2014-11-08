require 'spec_helper'

describe CustomerDecorator do
  describe 'display_phone_number' do
    it "adds dashes and parenthasies to the phone number" do
      bob = Fabricate(:customer, phone_number: "555-777-8888")
      expect(bob.phone_number).to eq("5557778888")

      expect(bob.decorate.display_phone_number).to eq("(555)777-8888")
    end
  end

  describe 'name' do
    it "combines the first and last name into one string" do
      bob = Fabricate(:customer, first_name: "Bob", last_name: "Burger")
      expect(bob.decorate.name).to eq("Bob Burger")
    end 
  end
end