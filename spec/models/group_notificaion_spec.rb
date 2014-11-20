require 'spec_helper'

describe GroupNotification do
  it { should validate_presence_of(:group_id)}
  it { should validate_presence_of(:group_message)}
end 
