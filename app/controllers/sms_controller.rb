class SmsController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def text

    message = "Hey bro! Thanks for signing up! You said - #{params[:Body]} "

    response = Twilio::TwiML::Response.new do |r|
      r.Message(message)
    end
 
    render_twiml response
  end
end