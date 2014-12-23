require 'spec_helper'

describe SmsOperatorController do
  describe 'POST sms_handler' do
    let(:bob_business_owner) { Fabricate(:business_owner, full_name: "Bob's Burgers") }
    let(:params) do
      {
      "ToCountry"=>"US", 
      "ToState"=>"", 
      "SmsMessageSid"=>"SM741c7ef69ee6ffd44c25c5e76f61d38d", 
      "NumMedia"=>"0", 
      "ToCity"=>"", 
      "FromZip"=>"33316", 
      "SmsSid"=>"SM741c7ef69ee6ffd44c25c5e76f61d38d", 
      "FromState"=>"FL", 
      "SmsStatus"=>"received", 
      "FromCity"=>"FT LAUDERDALE", 
      "Body"=>"sign me up for LUNCH", 
      "FromCountry"=>"US", 
      "To"=>"+18554965033", 
      "ToZip"=>"", 
      "MessageSid"=>"SM741c7ef69ee6ffd44c25c5e76f61d38d", 
      "AccountSid"=>"ACb62e32327e8ec258781341a039e65c46", 
      "From"=>"+19546381523", 
      "ApiVersion"=>"2010-04-01"
      }
    end


    it "[renders the response text]" do
      lunch_group = Fabricate(:group, name: 'LUNCH', business_owner: bob_business_owner)
      post :sms_handler, params
      expect(response.body).to match /LUNCH/im
    end

    it "[creates the customer if they don't exist and the group does exixt]" do
      lunch_group = Fabricate(:group, name: 'LUNCH', business_owner: bob_business_owner)
      post :sms_handler, params
      expect(bob_business_owner.customers.first.phone_number).to eq('9546381523')
    end

    it "[finds the customer if they do exist]" do
      tom = Fabricate(:customer, business_owner: bob_business_owner)
      post :sms_handler, params
      expect(Customer.count).to eq(1)
    end

    it "adds the customer to the group " do
      lunch_group = Fabricate(:group, name: 'LUNCH', business_owner: bob_business_owner)
      post :sms_handler, params
      expect(lunch_group.customers.count).to eq(1)
    end

    it "[sets the correct message for twilio to send back]" do
      lunch_group = Fabricate(:group, name: 'LUNCH', business_owner: bob_business_owner)
      post :sms_handler, params
      expect(response.body).to match /Thanks' for subscribing to LUNCH txt list with Bob's Burgers!/im
    end

    context "[the group doesn't exist]" do
      it "sets the correct message for twilio to send back" do
        post :sms_handler, params
        expect(response.body).to match /Oops, it looks like you tried to joing a txt list that doesn't exist. Please make sure you type in the keyword in all UPPERCASE letters and try again./im
      end
    end
  end
end