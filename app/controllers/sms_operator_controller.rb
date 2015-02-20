class SmsOperatorController < ApplicationController
  include Webhookable

  after_filter :set_header

  skip_before_action :verify_authenticity_token

  def sms_handler
    group = find_group_by_keyword(params[:Body])
    phone_number = params[:From][2..11]

    if group && !unsubscibe_customer?(params[:Body])
      customer = Customer.find_or_create_by(phone_number: phone_number, business_owner_id: group.business_owner.id)

      membership = Membership.new(group: group, customer: customer, current_business_owner: current_business_owner)
      membership.save
      message = group.reply_message
      AppMailer.keyword_email(group, customer).deliver
    elsif unsubscibe_customer?(params[:Body])
      CustomerUnsubscribe.new(phone_number)
    else
      message = "Oops, it looks like you tried to joing a txt list that doesn't exist. Please make sure you type in the keyword in all UPPERCASE letters and try again."
    end

    response = Twilio::TwiML::Response.new do |r|
      r.Message(message)
    end
    render_twiml response
  end

  private

  def find_group_by_keyword(string)
    group_list = Group.all.map {|g| g.name.downcase}
    keyword = group_list.detect { |group| string.downcase.scan(group).present? }

    Group.where('lower(name) = ?', keyword).first if keyword
  end

  def unsubscibe_customer?(string)
    string.downcase =~ /stop/
  end
end

