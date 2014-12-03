class Group < ActiveRecord::Base
  belongs_to :business_owner
  has_many :memberships
  has_many :customers, through: :memberships
  has_many :group_notifications
  has_many :notifications, through: :group_notifications


  validates_presence_of :name, :business_owner_id
  validates :name, uniqueness: { scope: :business_owner }

  after_destroy :delete_memberships

  private

  def delete_memberships
    Membership.delete_all(group_id: id)
  end 

end