class InquiriesController < ApplicationController
  def new
    @inquiry = Inquiry.new
    render :new
  end

  def create 
    @inquiry = Inquiry.new(params[:inquiry])
    @inquiry.phone_number = Customer.format_phone_number(@inquiry.phone_number)
    if @inquiry.valid?
      AppMailer.customer_inquiry(params).deliver
      flash[:success] = "Thanks for the email. We'll get back to you shortly!"
      redirect_to new_inquiry_path 
    else
      flash[:error] = "Please fix the errors below."
      render :new
    end
  end 
end   