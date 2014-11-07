def sign_in_user(user=nil)
  logged_in_user = user || Fabricate(:user)
  visit new_user_session_path
  fill_in "user_email", with: logged_in_user.email
  fill_in "user_password", with: logged_in_user.password
  click_button "Login"
  expect(page).to have_content("Signed in successfully.")  
end

def fill_in_customer_form(options={})
    fill_in "First Name", with: options[:first_name]
    fill_in "Last Name", with: options[:last_name]
    fill_in "Phone Number", with: options[:phone_number] 
end