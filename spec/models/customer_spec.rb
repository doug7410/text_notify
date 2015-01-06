require 'spec_helper'

describe Customer do
  it { should validate_presence_of(:phone_number)}
  it { should validate_numericality_of(:phone_number)}
  it { should ensure_length_of(:phone_number).is_equal_to(10) }
  it { should validate_uniqueness_of(:phone_number).scoped_to(:business_owner_id) }

  describe ".format_phone_number(number)" do
    it "strips out non-numeric characters" do
      phone_number = "555-777-8888"
      expect(Customer.format_phone_number(phone_number)).to eq("5557778888")
    end
  end

  describe '.import' do
    let(:import_array) do
      [
        {
          :full_name=>"Tom",
          :phone_number=>"555-555-5555", 
          :groups=>"tacos;buritos"
        },
        {
          :full_name=>"Dave",
          :phone_number=>"444-555-777", 
          :groups=>"tacos"
        }
      ]
    end

    it 'creates a customer for each valid row in the import array' do
      Customer.import(import_array)
      expect(Customer.count).to eq(1)
    end
    
    
    context 'adding to groups that belong to the business owner' do
      bob = Fabricate(:business_owner)
      let(:tacos) { Fabricate(:group, name: 'tacos', business_owner: bob) }
      let(:buritos) { Fabricate(:group, name: 'buritos', business_owner: bob) }
      
      it 'adds the customer to the groups' do
        Customer.import(import_array)
        expect(Customer.first.groups).to include([tacos, buritos])
      end
    end

    context 'adding to groups not belonging to the business owner'
  end
  
end 
