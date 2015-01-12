require 'spec_helper'
include Warden::Test::Helpers

describe ApplicationHelper do
  let(:bob_business_owner) { Fabricate(:business_owner) }
  before { sign_in bob_business_owner }

  describe 'format_datetime(dt)' do
    it 'returns nil if the object passed in is nil' do
      datetime = DateTime.new(2001,2,3)
      formated_datetime = format_datetime(datetime)
      expect(format_datetime).to eq('1/1/1')
    end
    it 'returns the datetime in the correct time zone'
    it 'returns the datetime in the correct format'
  end
end