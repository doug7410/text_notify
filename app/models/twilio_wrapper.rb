class TwilioWrapper
  attr_reader :response, :error_message
  @client = Twilio::REST::Client.new(ENV['twilio_account_sid'], ENV['twilio_auth_token'])

  def initialize(options={})
    @response = options[:response]
    @error_message = options[:error_message]
  end

  def self.send_message(options={})
    
    if Rails.env.production?
      app_url = "http://www.pijontxt.com/twilio_callback"
    elsif Rails.env.staging?
      app_url = "http://www.text-notify-staging.herokuapp.com/twilio_callback"
    else
      app_url = nil
    end

    begin
      response = @client.account.messages.create({
        :from => '+18554965033',  
        :to => options[:to], 
        :body => options[:body],
        :status_callback => app_url
      })

      message = @client.account.messages.get(response.sid)
      error_message = message.error_message

      if error_message
        new(error_message: "There was a problem with the phone number - (#{error_message}) - Please verify that the number is correct.")
      else
        new(response: response)
      end
    rescue Twilio::REST::RequestError => e
      new(error_message: e.message)
    end
  end

  def self.message_status(sid)
    message = @client.account.messages.get(sid)
    message.status
  end 

  def successful?
    response.present?  
  end
end 
