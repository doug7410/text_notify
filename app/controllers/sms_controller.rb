class SmsController
  skip_before_action :verify_authenticity_token
    
  def index
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "Hey Monkey. Thanks for the message!"
    end
    twiml.text
  end

end 