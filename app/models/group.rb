class Group < ActiveRecord::Base
  belongs_to :user
  has_many :customer_groups
  has_many :customers, through: :customer_groups

  validates_presence_of :name, :user_id
  validates :name, uniqueness: { scope: :user }
end