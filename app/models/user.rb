class User < ActiveRecord::Base
  has_many :customers
  has_many :group_notifications
  has_many :groups
  has_many :group_notifications, through: :groups
  validates :full_name, presence: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
