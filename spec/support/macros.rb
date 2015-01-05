def fill_in_customer_form(options={})
  fill_in 'customer_full_name', with: options[:full_name]
  fill_in 'customer_phone_number', with: options[:phone_number]
end
