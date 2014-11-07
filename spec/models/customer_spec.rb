require 'spec_helper'

describe Customer do
  it { should validate_presence_of(:first_name)}
  it { should validate_presence_of(:last_name)}
  it { should validate_presence_of(:phone_number)}
  it { should ensure_length_of(:phone_number).is_at_least(10) }

  it "[should remove non-numeric characters from the phone number before save]" do
    bob = Fabricate(:customer, phone_number: '555-666-7777')   
    expect(bob.reload.phone_number).to eq('5556667777')
  end
end 
