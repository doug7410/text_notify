class Group < ActiveRecord::Base
  belongs_to :user
  has_many :customer_groups
  has_many :customers, through: :customer_groups
  has_many :group_notifications
  has_many :notifications, through: :group_notifications


  validates_presence_of :name, :user_id
  validates :name, uniqueness: { scope: :user }

  after_destroy :delete_customer_groups

  private

  def delete_customer_groups
    CustomerGroup.delete_all group_id: id
  end 

end