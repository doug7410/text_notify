require 'spec_helper' 

describe TwilioWrapper do
  describe TwilioWrapper::REST do
    describe TwilioWrapper::REST::Client do
      describe '#send_message', :vcr do
         response = TwilioWrapper::REST::Client.send_message(body:'test message', to: '9546381523')
         # binding.pry
         expect(response).to be_successful
      end
    end
  end
end