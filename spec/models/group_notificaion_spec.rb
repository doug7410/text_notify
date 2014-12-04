require 'spec_helper'

describe GroupNotification do
  it { should validate_presence_of(:group_id)}
  it { should validate_presence_of(:group_message)}
  it { should validate_presence_of(:business_owner)}
end 
