require 'spec_helper'

describe Notification do
  it { should validate_presence_of(:message)}
  it { should validate_presence_of(:customer)}
end