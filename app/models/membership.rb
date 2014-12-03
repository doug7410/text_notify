class Membership < ActiveRecord::Base
  attr_accessor :current_business_owner

  belongs_to :customer
  belongs_to :group

  validates_presence_of :customer, :group
  validates_uniqueness_of :group, scope: :customer

  after_validation :ensure_customer_and_group_belong_to_business_owner
    
  private

  def ensure_customer_and_group_belong_to_business_owner
    if current_business_owner
      if group.business_owner == current_business_owner and customer.business_owner == current_business_owner
        true
      else
        errors.add :customer, "this is not your customer"
      end
    end
  end
end