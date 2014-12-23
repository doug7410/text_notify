class SmsOperatorController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def sms_handler

    message = "Hey bro! Thanks for signing up! You said - #{params[:Body]} "

    response = Twilio::TwiML::Response.new do |r|
      r.Message(message)
    end
    binding.pry
    render_twiml response
  end
end


# Parameters: {
#   "ToCountry"=>"US", 
#   "ToState"=>"", 
#   "SmsMessageSid"=>"SM741c7ef69ee6ffd44c25c5e76f61d38d", 
#   "NumMedia"=>"0", 
#   "ToCity"=>"", 
#   "FromZip"=>"33316", 
#   "SmsSid"=>"SM741c7ef69ee6ffd44c25c5e76f61d38d", 
#   "FromState"=>"FL", 
#   "SmsStatus"=>"received", 
#   "FromCity"=>"FT LAUDERDALE", 
#   "Body"=>"People ", 
#   "FromCountry"=>"US", 
#   "To"=>"+18554965033", 
#   "ToZip"=>"", 
#   "MessageSid"=>"SM741c7ef69ee6ffd44c25c5e76f61d38d", 
#   "AccountSid"=>"ACb62e32327e8ec258781341a039e65c46", 
#   "From"=>"+19546381523", 
#   "ApiVersion"=>"2010-04-01"
# }
