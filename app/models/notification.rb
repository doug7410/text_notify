class Notification < ActiveRecord::Base
  belongs_to :customer  

  validates_presence_of :customer, :message

  def send_text_message
    account_sid = ENV['twilio_account_sid'] 
    auth_token = ENV['twilio_auth_token'] 
    
    begin
      client = Twilio::REST::Client.new account_sid, auth_token      
      
      client.account.messages.create({
        :from => '+15619238682',  
        :to => self.customer.phone_number, 
        :body => self.message  
      })
    rescue Twilio::REST::RequestError => e
      puts e.message
    end
  end
end