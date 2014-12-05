class Group < ActiveRecord::Base
  belongs_to :business_owner
  has_many :memberships, dependent: :destroy
  has_many :customers, through: :memberships
  
  accepts_nested_attributes_for :memberships

  has_many :group_notifications
  has_many :notifications, through: :group_notifications


  validates_presence_of :name, :business_owner_id
  validates :name, uniqueness: { scope: :business_owner }

end