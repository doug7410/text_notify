class Customer < ActiveRecord::Base
  has_many :notifications

  validates_presence_of :first_name, :last_name, :phone_number
  validates_uniqueness_of :phone_number 
  validates :phone_number, :phone_number => {:ten_digits => true, :message => "please enter a 10 digit phone number, ex: 555-123-4567"}

  # Question:
  # this is the only way I can get the behavior I want, but it makes my test fail
  before_validation :format_phone_number

  private

  def format_phone_number
    self.phone_number = self.phone_number.gsub(/\D/, "")
  end
end