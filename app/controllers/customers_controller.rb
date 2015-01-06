class CustomersController < ApplicationController
  before_filter :authenticate_business_owner!
  before_filter :find_customer, only: [:show, :update]
  before_filter :current_business_owner_customers, only: [:index, :create]

  def index
    @customer = Customer.new

    respond_to do |format|
      format.html
      format.js do
        render json: autosearch_customers.map { |c|
          {
            phone: c.phone_number,
            label: "#{c.full_name} - #{c.phone_number}",
            value: c.full_name
          }
        }
      end
    end
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      flash[:success] = "#{@customer.full_name} - #{@customer.phone_number} has been added."
      redirect_to :customers
    else
      render :index
    end
  end

  def show; end

  def update
    if @customer.update(customer_params)
      flash[:success] = 'Customer successfully updated'
    end
    render :show
  end

  def import
    customers = SmarterCSV.process(params[:file].tempfile)
    binding.pry
    Customer.import(customers)
    redirect_to :customers
    flash[:success] = 'Customers successfully imported.'
  end

  private

  def current_business_owner_customers
    id = current_business_owner.id
    customers = Customer.where(business_owner_id: id)
    @customers =customers.paginate(page: params[:page])
  end

  def autosearch_customers
    autosearch_query = "lower(full_name) LIKE ? OR phone_number LIKE ?", "%#{params[:term].downcase}%", "%#{params[:term]}%"
    current_business_owner.customers.where(autosearch_query)
  end

  def find_customer
    @customer = Customer.find(params[:id]).decorate
  end

  def customer_params
    customer_hash = params.require(:customer).permit(:full_name, :phone_number)
    phone_number = customer_hash[:phone_number]
    customer_hash.merge(
        business_owner: current_business_owner,
        phone_number: formated_phone_number(phone_number)
      )
  end
end
