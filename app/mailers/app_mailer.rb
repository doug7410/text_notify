class AppMailer < ActionMailer::Base
  def customer_inquiry(params)
    @params = params[:inquiry]
    mail from: @params[:email], to: 'dstein-phins@hotmail.com', subject: "New customer inquiry from TextNotify!"
  end

  def keyword_email(group, customer, sms)
    @customer = customer
    @group = group
    @sms = sms
    subject = "New lead from PijonTxt #{group.name.upcase} keyword campaign."
    mail from: 'leads@pijontxt.com', to: group.forward_email, subject: subject
  end 
end 