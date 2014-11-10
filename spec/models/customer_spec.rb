require 'spec_helper'

describe Customer do
  it { should validate_presence_of(:first_name)}
  it { should validate_presence_of(:last_name)}
  it { should validate_presence_of(:phone_number)}
  it { should validate_uniqueness_of(:phone_number)}
  it { should validate_numericality_of(:phone_number)}
  it { should ensure_length_of(:phone_number).is_equal_to(10) }

  
end 
