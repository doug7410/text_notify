require 'spec_helper'

describe Notification do
  it { should validate_presence_of(:message)}
  it { should validate_presence_of(:customer_id)}
  it { should validate_presence_of(:business_owner)}

end