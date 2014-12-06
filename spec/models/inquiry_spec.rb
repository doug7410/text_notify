require 'spec_helper'

describe Inquiry do
  it { should validate_presence_of(:name)}
  it { should validate_presence_of(:email)}
  it { should validate_presence_of(:message)}
  it { should validate_numericality_of(:phone_number)}
  it { should ensure_length_of(:phone_number).is_equal_to(10) }
  it { should allow_value("email@example.com").for(:email) }
  it { should_not allow_value('bar').for(:email) }

end