class CustomerDecorator < Draper::Decorator
  delegate_all

  def display_phone_number
    object.phone_number.insert(3, '-').insert(-5, '-')
  end

  def name
    object.first_name + " " + object.last_name
  end

end