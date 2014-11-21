class CustomersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_customer, only: [:show, :update]


  def index
    @customers = Customer.all.where("user_id = ?", current_user.id).decorate
    @customer = Customer.new
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params.merge({phone_number: Customer.format_phone_number(customer_params[:phone_number])}))
    @customers = Customer.all.where("user_id = ?", current_user.id).decorate

    if @customer.save
      flash[:success] = "#{@customer.first_name} #{@customer.last_name} has been successfully added."
      redirect_to :customers
    else
      render :index
    end
  end

  def show; end

  def update
    if @customer.update(customer_params.merge({phone_number: Customer.format_phone_number(customer_params[:phone_number])}))
      flash[:success] = "Customer - #{@customer.decorate.name} has been updated."
    end
    render :show
  end

  def destroy
    @customers = Customer.all.decorate
    if Customer.exists?(params[:id])
      customer = Customer.find(params[:id])
      customer.destroy
      flash[:danger] = "#{customer.decorate.name} has been deleted."
    else
      flash[:warning] = "That customer does not exist."
    end
    @customer = Customer.new
    render :index
  end

  private 

  def find_customer
    @customer = Customer.find(params[:id]).decorate
  end

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :phone_number, :user_id)
  end 

  
end