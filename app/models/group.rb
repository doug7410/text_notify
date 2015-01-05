class Group < ActiveRecord::Base
  belongs_to :business_owner
  has_many :memberships, dependent: :destroy
  has_many :customers, through: :memberships

  accepts_nested_attributes_for :memberships

  has_many :group_notifications
  has_many :notifications, through: :group_notifications

  validates_presence_of :name, :business_owner_id
  validates_uniqueness_of :name, :case_sensitive => false
  validates :name, length: {
    maximum: 1,
    tokenizer: lambda { |str| str.split(/\s+/) },
    too_long: "Please choose a name that is only %{count} word."
  }

end
