require 'spec_helper'

describe Customer do
  it { should validate_presence_of(:first_name)}
  it { should validate_presence_of(:last_name)}
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
  
end 
