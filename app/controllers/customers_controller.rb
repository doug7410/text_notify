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

  def destroy
    @customers = Customer.all.decorate
    if Customer.exists?(params[:id])
      customer.destroy
      flash[:danger] = "#{customer.decorate.name} has been deleted."
    else
      flash[:warning] = "That customer does not exist."
    end
    
    render :index
  end

  private 

  def customer
    customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :phone_number)
  end 
end