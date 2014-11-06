class Customer < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :phone_number

  validates_length_of :phone_number, minimum: 10  

  def format_phone_number(phone_number)

  end
end