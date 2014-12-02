def fill_in_customer_form(options={})
  fill_in "First Name", with: options[:first_name]
  fill_in "Last Name", with: options[:last_name]
  fill_in "Phone Number", with: options[:phone_number] 
end