require 'spec_helper' 

describe TwilioWrapper do
  describe TwilioWrapper::REST do
    describe TwilioWrapper::REST::Client do
      describe '#send_message', :vcr do
         
         it "[sends the text message with a valid phone number and body]" do
           result = TwilioWrapper::REST::Client.send_message(body:'test message', to: '9546381523')
           expect(result).to be_successful
         end

         it "[does not return an error message with a valid phone_number and body]" do
           result = TwilioWrapper::REST::Client.send_message(body:'test message', to: '9546381523')
           expect(result.error_message).to be_nil
         end

         it "[does not send the text message with an empty body]" do
           result = TwilioWrapper::REST::Client.send_message(body:'', to: '9546381523')
           expect(result).not_to be_successful
         end

         it "[returns an error message with an empty body]" do
           result = TwilioWrapper::REST::Client.send_message(body:'', to: '9546381523')
           expect(result.error_message).not_to be_nil
         end

         it "[returns an error message with an invalid phone number]" do
          result = TwilioWrapper::REST::Client.send_message(body:'test message', to: '12345')
          expect(result.error_message).not_to be_nil
         end

         it "[returns an error message if twilio can't send to the phone number]" do
          result = TwilioWrapper::REST::Client.send_message(body:'test message', to: '5005550001')
          expect(result.error_message).not_to be_nil
         end
      end
    end
  end
end 