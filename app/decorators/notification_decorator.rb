class NotificationDecorator < Draper::Decorator
  delegate_all

  def sent_date
    object.sent_date.strftime("%m/%d/%Y - %i:%M%p") if object.sent_date
  end 

end