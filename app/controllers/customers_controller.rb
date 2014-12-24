class CustomersController < ApplicationController
  before_filter :authenticate_business_owner!
  before_filter :find_customer, only: [:show, :update]


  def index
    @customers = Customer.all.where("business_owner_id = ?", current_business_owner.id).decorate
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params.merge({business_owner: current_business_owner ,phone_number: Customer.format_phone_number(customer_params[:phone_number])}))
    @customers = Customer.all.where("business_owner_id = ?", current_business_owner.id).decorate

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


  private 

  def find_customer
    @customer = Customer.find(params[:id]).decorate
  end

  def customer_params
    params.require(:customer).permit(:full_name, :phone_number)
  end 

  
end