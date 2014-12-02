def sign_in_business_owner(business_owner=nil)
  logged_in_business_owner = business_owner || Fabricate(:business_owner)
  visit new_business_owner_session_path
  fill_in "business_owner_email", with: logged_in_business_owner.email
  fill_in "business_owner_password", with: logged_in_business_owner.password
  click_button "Login"
  expect(page).to have_content("Signed in successfully.")  
end

def fill_in_customer_form(options={})
    fill_in "First Name", with: options[:first_name]
    fill_in "Last Name", with: options[:last_name]
    fill_in "Phone Number", with: options[:phone_number] 
end