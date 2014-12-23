require 'spec_helper'

describe SmsHandlerService do
  describe '.find_group' do
    it "[returns a group if one exists]" do
      lunch_group = Fabricate(:group, name: 'LUNCH', business_owner: Fabricate(:business_owner))
      string = "sign me up for LUNCH please!"
      expect(SmsHandlerService.find_group(string)).to eq(lunch_group)
    end

    it "[returns nil if no group is found]" do
      lunch_group = Fabricate(:group, name: 'LUNCH', business_owner: Fabricate(:business_owner))
      string = "sign me up for DINNER please!"
      expect(SmsHandlerService.find_group(string)).to eq(nil)
    end
  end
end