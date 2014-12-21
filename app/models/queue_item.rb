class QueueItem < ActiveRecord::Base
  belongs_to :business_owner
  belongs_to :notification
end
