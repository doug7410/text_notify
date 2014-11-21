require 'spec_helper'

describe CustomerGroup do
  it { should validate_presence_of(:customer)}
  it { should validate_presence_of(:group)}
end 
