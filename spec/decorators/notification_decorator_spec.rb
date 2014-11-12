require 'spec_helper'

describe NotificationDecorator do
  describe 'sent_date' do
    it "formats the date for display" do
      bob = Fabricate(:customer, phone_number: "5557778888")
      notification = Fabricate(:notification, sent_date: Time.now, customer: bob)
      expect(notification.decorate.sent_date).to eq('123')
    end
  end
end