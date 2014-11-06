def sign_in_user(user=nil)
  logged_in_user = user || Fabricate(:user)
  visit new_user_session_path
  fill_in "user_email", with: logged_in_user.email
  fill_in "user_password", with: logged_in_user.password
  click_button "Login"
  expect(page).to have_content("Signed in successfully.")  
end