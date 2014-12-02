class Group < ActiveRecord::Base
  belongs_to :business_owner
  has_many :customer_groups
  has_many :customers, through: :customer_groups
  has_many :group_notifications
  has_many :notifications, through: :group_notifications


  validates_presence_of :name, :business_owner_id
  validates :name, uniqueness: { scope: :business_owner }

  after_destroy :delete_customer_groups

  private

  def delete_customer_groups
    CustomerGroup.delete_all group_id: id
  end 

end