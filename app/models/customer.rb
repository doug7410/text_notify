class Customer < ActiveRecord::Base
  belongs_to :business_owner
  has_many :notifications, -> { order "created_at ASC" }, dependent: :destroy
  
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  validates_presence_of :first_name, :last_name, :phone_number
  validates :phone_number, uniqueness: { scope: :business_owner }
  validates :phone_number, length: { is: 10 }
  validates :phone_number, numericality: { only_integer: true }


  def self.format_phone_number(number) 
    number.gsub(/\D/, "")
  end


end