class SmsOperatorController < ApplicationController
  include Webhookable

  after_filter :set_header

  skip_before_action :verify_authenticity_token

  def sms_handler
    binding.pry
    group = find_group_by_keyword(params[:Body])
    phone_number = params[:From][2..11]

    binding.pry
    if group && !unsubscibe_customer?(params[:Body])
      binding.pry
      customer = Customer.find_or_create_by(phone_number: phone_number, business_owner_id: group.business_owner.id)

      membership = Membership.new(group: group, customer: customer, current_business_owner: current_business_owner)
      membership.save

      message = group.reply_message
      binding.pry
      AppMailer.keyword_email(group, customer, params).deliver
      binding.pry
    elsif unsubscibe_customer?(params[:Body])
      CustomerUnsubscribe.new(phone_number)
    else
      message = "Oops, it looks like you tried to joing a txt list that doesn't exist. Please make sure you type in the keyword in all UPPERCASE letters and try again."
    end

    binding.pry
    response = Twilio::TwiML::Response.new do |r|
      binding.pry
      r.Message(message)
      binding.pry
    end
    render_twiml response

    binding.pry
  end

  private

  def find_group_by_keyword(string)
    group_list = Group.all.map {|g| g.name.downcase}
    keyword = group_list.detect { |group| string.downcase == group }

    Group.where('lower(name) = ?', keyword).first if keyword
  end

  def unsubscibe_customer?(string)
    string.downcase =~ /stop/
  end
end

