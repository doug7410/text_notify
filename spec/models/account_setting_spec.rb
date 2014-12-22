require 'spec_helper'

describe AccountSetting do
  it { should validate_presence_of(:default_send_now_message)}
  it { should validate_presence_of(:default_add_to_queue_message)}
  it { should validate_presence_of(:default_send_from_queue_message)}

end