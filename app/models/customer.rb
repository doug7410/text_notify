class Customer < ActiveRecord::Base
  belongs_to :user
  has_many :notifications

  validates_presence_of :first_name, :last_name, :phone_number
  validates :phone_number, uniqueness: { scope: :user }
  validates :phone_number, length: { is: 10 }
  validates :phone_number, numericality: { only_integer: true }

end