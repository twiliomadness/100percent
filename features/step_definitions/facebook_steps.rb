Given /^Facebook user "([^"]*)" exists$/ do |user_name|
  mock_user = mock_user_data(user_name)

  OmniAuth.config.test_mode = true
  facebook_info = {
        "id" => '12345',
        "link" => 'http://facebook.com/josevalim',
        "email" => mock_user[:email],
        "first_name" => mock_user[:first],
        "last_name" => mock_user[:last],
        "website" => 'http://blog.plataformatec.com.br'
  }
  OmniAuth.config.mock_auth[:facebook] = {
            "uid" => '12345',
            "provider" => 'facebook',
            "user_info" => {"nickname" => "#{mock_user[:first].downcase}#{mock_user[:last].downcase}"},
            "credentials" => {"token" => 'plataformatec'},
            "extra" => {"user_hash" => facebook_info}
          }
end

Given /^I authorize with Facebook as "([^"]*)"$/ do |user_name|
  Given "Facebook user \"#{user_name}\" exists"
  visit root_path
  click_link "fb_login_button"
end

Then /^I should be logged into the app$/ do
  page.should_not have_content("Could not authorize you from Facebook")
end

Then /^User "([^"]*)" should have birthday set$/ do |user_name|
  mock_user = mock_user_data(user_name)
  user = User.where(:email =>  mock_user[:email]).first
  user.date_of_birth.should_not be_nil
end

