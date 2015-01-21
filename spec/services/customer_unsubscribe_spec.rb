require 'spec_helper'

describe CustomerUnsubscribe do
  describe '#unsubscribe_customer' do
    let!(:jim_business_owner) { Fabricate(:business_owner) }
    let!(:bob_business_owner) { Fabricate(:business_owner) }
    let!(:customer1) do  
      Fabricate(
        :customer,
        business_owner: bob_business_owner,
        phone_number: '9546381523'
      )
    end
    let!(:customer2) do  
      Fabricate(
        :customer,
        business_owner: jim_business_owner,
        phone_number: '9546381523'
      )
    end
    let!(:notification1) { Fabricate(:notification, customer: customer1) }
    let!(:notification2) { Fabricate(:notification, customer: customer1) }
    let!(:notification3) { Fabricate(:notification, customer: customer1) }
    let!(:queue_item1) { Fabricate(:queue_item, notification: notification1) }
    let!(:queue_item2) { Fabricate(:queue_item, notification: notification2) }

    it '[deletes all occurences of the customer]' do
      CustomerUnsubscribe.new('9546381523')
      expect(Customer.count).to eq(0)
    end
    
    it '[deletes all notifications related to the customer]' do
      CustomerUnsubscribe.new('9546381523')
      expect(Notification.count).to eq(0)
    end

    it '[deletes all the queue items related to the customer]' do
      CustomerUnsubscribe.new('9546381523')
      expect(QueueItem.count).to eq(0)
    end
  end 
end