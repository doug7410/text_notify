class SmsController < ApplicationController
  skip_before_action :verify_authenticity_token
    
  def index
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "Hey Monkey. Thanks for the message!"
    end
    twiml.text

    render nothing: true
  end

end 