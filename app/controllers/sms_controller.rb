class SmsController < ApplicationController
    
  def create
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "Hey Monkey. Thanks for the message!"
    end
    twiml.text
    
    render nothing: true
  end

end 