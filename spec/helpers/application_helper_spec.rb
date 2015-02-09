require 'spec_helper'

describe ApplicationHelper do
  let(:bob_business_owner) { Fabricate(:business_owner) }

  describe 'format_datetime(dt)' do
    it 'returns nil if the object passed in is nil'
    it 'returns the datetime in the correct time zone'
    it 'returns the datetime in the correct format'
  end
end