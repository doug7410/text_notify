class User < ActiveRecord::Base
  has_many :customers

  validates :full_name, presence: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
