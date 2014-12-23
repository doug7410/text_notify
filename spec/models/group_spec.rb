require 'spec_helper'

describe Group do
  it { should validate_presence_of(:name)}
  it { should validate_presence_of(:business_owner_id)}
  it { should validate_uniqueness_of(:name)}
end 
