class CustomerDecorator < Draper::Decorator
  delegate_all

  def display_phone_number
      object.phone_number.insert(0,'(').insert(4, ')').insert(-5, '-') unless object.phone_number.blank?
  end

  def name
    if object.full_name.present?
      object.full_name
    else
      'generic customer'
    end
  end

end