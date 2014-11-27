class TwilioCallbackController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :twilio_authenticate
  
  def status
    notification = Notification.where("sid = ?", params[:MessageSid]).first
    notification.status = params[:MessageStatus]
    notification.error_code = params[:ErrorCode]
    notification.save
    render nothing: true
  end

  private

  def twilio_authenticate
    redirect_to root_path unless ENV['twilio_account_sid'] == params[:AccountSid]
  end
end