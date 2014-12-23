class SmsOperatorController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def sms_handler

    group = SmsHandlerService.find_group(params[:Body])

    if group
      customer = Customer.find_or_create_by(phone_number: params[:From][2..11], business_owner_id: group.business_owner.id)

      membership = Membership.new(group: group, customer: customer, current_business_owner: current_business_owner)
      membership.save
      message = "Thanks' for subscribing to #{group.name} txt list with #{group.business_owner.full_name}!"
    else
      message = "Oops, it looks like you tried to joing a txt list that doesn't exist. Please make sure you type in the keyword in all UPPERCASE letters and try again."
    end

    response = Twilio::TwiML::Response.new do |r|
      r.Message(message)
    end
    render_twiml response
  end
end

