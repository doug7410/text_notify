class TwilioCallbackController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def status
    notification = Notification.where("sid = ?", params[:MessageSid]).first
    notification.status = params[:MessageStatus]
    notification.error_code = params[:ErrorCode]
    notification.save
  end

  private

  def twilio_authenticate

  end
end