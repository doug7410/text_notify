module TwilioWrapper
  module REST
    class Client

      attr_reader :response, :error_message

      def initialize(options={})
        @response = options[:response]
        @error_message = options[:error_message]
      end

      def self.send_message(options={})
        begin
          client = Twilio::REST::Client.new(ENV['twilio_account_sid'], ENV['twilio_auth_token'])

          response = client.account.messages.create({
            :from => '+15619238682',  
            :to => options[:to], 
            :body => options[:body]  
          })

          message = client.account.messages.get(response.sid)
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

      def successful?
        response.present?  
      end
      
    end
  end
end 


