require 'spec_helper' 

describe TwilioWrapper do
  describe '#send_message' do
     
     it "[sends the text message with a valid phone number and body]", :vcr do
       result = TwilioWrapper.send_message(body:'test message', to: '9546381523')
       expect(result).to be_successful
     end

     it "[does not return an error message with a valid phone_number and body]", :vcr do
       result = TwilioWrapper.send_message(body:'test message', to: '9546381523')
       expect(result.error_message).to be_nil
     end

     it "[does not send the text message with an empty body]", :vcr do
       result = TwilioWrapper.send_message(body:'', to: '9546381523')
       expect(result).to eq(65454)
     end

     it "[returns an error message with an empty body]", :vcr do
       result = TwilioWrapper.send_message(body:'', to: '9546381523')
       expect(result.error_message).not_to be_nil
     end

     it "[returns an error message with an invalid phone number]", :vcr do
      result = TwilioWrapper.send_message(body:'test message', to: '12345')
      expect(result.error_message).not_to be_nil
     end

     it "[returns an error message if twilio can't send to the phone number]", :vcr do
      result = TwilioWrapper.send_message(body:'test message', to: '5005550001')
      expect(result.error_message).not_to be_nil
     end
  end

  describe '#message_status', :vcr do

    it "sets the message status" do
      expect(TwilioWrapper.message_status('SM073e2f4c26e64eafa589d77229c07877')).to eq('delivered')
    end 
  end
end 