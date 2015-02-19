class Customer < ActiveRecord::Base
  belongs_to :business_owner
  has_many :notifications, -> { order 'created_at ASC' }

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  validates_presence_of :phone_number
  validates :phone_number, uniqueness: { scope: :business_owner_id }
  validates :phone_number, length: { is: 10 }
  validates :phone_number, numericality: { only_integer: true }

  self.per_page = 10

  def self.import(import_array, business_owner_id)
    customer_count = 0
    import_array.each do |import_row|
      customer = find_or_create_by(
        phone_number: format_phone_number(import_row[:phone_number]),
        business_owner_id: business_owner_id
      )
      
      customer.update(full_name: import_row[:full_name])
      if customer.valid?
        Customer.add_import_customer_to_groups(import_row, customer, business_owner_id)
        customer_count += 1
      end
    end
    customer_count
  end

  def self.format_phone_number(number)
    number.to_s.gsub(/\D/, '')
  end

  # private

  def self.add_import_customer_to_groups(import_row, customer, business_owner_id)
    return nil unless customer
    group_names = import_row[:groups].split(';')
    group_names.each do |name|
      group = Group.where("lower(name) = ?", name.downcase).first
      Membership.create(customer: customer, group: group)
    end
  end
end
