require 'spec_helper'

describe Membership do
  it { should validate_presence_of(:customer)}
  it { should validate_presence_of(:group)}
end 
