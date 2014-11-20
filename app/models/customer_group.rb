class CustomerGroup < ActiveRecord::Base
  belongs_to :customer
  belongs_to :group

  validates_presence_of :customer, :group
end