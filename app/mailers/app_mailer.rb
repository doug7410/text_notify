class AppMailer < ActionMailer::Base
  def customer_inquiry(params)
    @params = params[:inquiry]
    mail from: @params[:email], to: 'dstein-phins@hotmail.com', subject: "New customer inquiry from TextNotify!"
  end 
end 