class CustomersController < ApplicationController
  before_filter :authenticate_user!


  def index
    @customers = Customer.all.decorate

  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.create(customer_params)

    if @customer.save
      flash[:success] = "#{@customer.first_name} #{@customer.last_name} has been successfully added."
      redirect_to :new_customer
    else
      render :new
    end
  end

  private 

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :phone_number)
  end 
end