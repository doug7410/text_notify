require 'spec_helper'

describe SmsOperatorController do
  describe 'POST sms_handler' do
    let(:bob_business_owner) do
      Fabricate(:business_owner, company_name: "Bob's Burgers")
    end

    let(:subscribe_params) do
      {
        'ToCountry' => 'US',
        'ToState' => '',
        'SmsMessageSid' => 'SM741c7ef69ee6ffd44c25c5e76f61d38d',
        'NumMedia' => '0',
        'ToCity' => '',
        'FromZip' => '33316',
        'SmsSid' => 'SM741c7ef69ee6ffd44c25c5e76f61d38d',
        'FromState' => 'FL',
        'SmsStatus' => 'received',
        'FromCity' => 'FT LAUDERDALE',
        'Body' => 'sign me up for LUNCH',
        'FromCountry' => 'US',
        'To' => '+18554965033',
        'ToZip' => '',
        'MessageSid' => 'SM741c7ef69ee6ffd44c25c5e76f61d38d',
        'AccountSid' => 'ACb62e32327e8ec258781341a039e65c46',
        'From' => '+19546381523',
        'ApiVersion' => '2010-04-01'
      }
    end

    context "when subscribing to a group" do
      it '[renders the response text]' do
        Fabricate(:group, name: 'LUNCH', business_owner: bob_business_owner)
        post :sms_handler, subscribe_params
        expect(response.body).to match(/LUNCH/im)
      end

      it '[creates the customer if they do not exist and the group does exixt]' do
        Fabricate(:group, name: 'LUNCH', business_owner: bob_business_owner)
        post :sms_handler, subscribe_params
        customer = bob_business_owner.customers.first
        expect(customer.phone_number).to eq('9546381523')
      end

      it '[finds the customer if they do exist]' do
        Fabricate(:customer, business_owner: bob_business_owner)
        post :sms_handler, subscribe_params
        expect(Customer.count).to eq(1)
      end

      it 'adds the customer to the group ' do
        Fabricate(:group, name: 'LUNCH', business_owner: bob_business_owner)
        post :sms_handler, subscribe_params
        expect(Group.first.customers.count).to eq(1)
      end

      it '[sets the correct message for twilio to send back]' do
        Fabricate(:group, name: 'LUNCH', business_owner: bob_business_owner)
        post :sms_handler, subscribe_params
        text = /Thanks' for subscribing to LUNCH txt list with Bob's Burgers!/im
        expect(response.body).to match(text)
      end
    end

    context '[the group does not exist]' do
      it 'sets the correct message for twilio to send back' do
        post :sms_handler, subscribe_params
        text = /Oops, it looks like you tried to joing a txt list that doesn't exist. Please make sure you type in the keyword in all UPPERCASE letters and try again./im
        expect(response.body).to match(text)
      end
    end

    context '[a customer unsubscribes]' do
      let(:unsubscribe_params) do
        {
          'ToCountry' => 'US',
          'ToState' => '',
          'SmsMessageSid' => 'SM741c7ef69ee6ffd44c25c5e76f61d38d',
          'NumMedia' => '0',
          'ToCity' => '',
          'FromZip' => '33316',
          'SmsSid' => 'SM741c7ef69ee6ffd44c25c5e76f61d38d',
          'FromState' => 'FL',
          'SmsStatus' => 'received',
          'FromCity' => 'FT LAUDERDALE',
          'Body' => 'STOP',
          'FromCountry' => 'US',
          'To' => '+18554965033',
          'ToZip' => '',
          'MessageSid' => 'SM741c7ef69ee6ffd44c25c5e76f61d38d',
          'AccountSid' => 'ACb62e32327e8ec258781341a039e65c46',
          'From' => '+19546381523',
          'ApiVersion' => '2010-04-01'
        }
      end

      let(:jim_business_owner) { Fabricate(:business_owner) }
        
      before do
        Fabricate(
              :customer,
              business_owner: bob_business_owner,
              phone_number: '9546381523'
            )
        Fabricate(
              :customer,
              business_owner: jim_business_owner,
              phone_number: '9546381523'
            )
      end

      it '[deletes all the customers with the From phone number]' do
        post :sms_handler, unsubscribe_params
        expect(Customer.count).to eq(0)
      end
      
      
    end
  end
end