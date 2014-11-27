class NotificationDecorator < Draper::Decorator
  delegate_all

  def sent_date
    object.created_on.strftime("%m/%d/%Y - %I:%M%p") if object.sent_date
  end

  def created_at
    object.created_at.strftime("%m/%d/%Y - %I:%M%p") if object.created_at
  end 

end