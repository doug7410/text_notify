class Customer < ActiveRecord::Base
  belongs_to :business_owner
  has_many :notifications, -> { order "created_at ASC" }
  
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  validates_presence_of :phone_number
  validates :phone_number, uniqueness: { scope: :business_owner_id }
  validates :phone_number, length: { is: 10 }
  validates :phone_number, numericality: { only_integer: true }

  self.per_page = 10

  def self.format_phone_number(number) 
    number.gsub(/\D/, "")
  end


end