Given /^I have submitted my first and last name$/ do
  @user = User.create!(User.default_attributes(:birthday => nil))
  @user.status = "pending_date_of_birth"
end

Given /^I have submitted my name and birthday$/ do
  @user = User.create!(User.default_attributes())
  @user.status = "pending_voter_info_confirmation"
end

Given /^I am a registered voter$/ do
  @voter = Voter.new(Voter.default_attributes())
  Voter.stub!(:find_by_name_and_date_of_birth).and_return(@voter)
end

Given  /^I can't be found in the voter lookup system$/ do 
  Given "I am not a registered voter"
  And "I confirm my voter info"
end

Given /^I am not a registered voter$/ do
  Given "I have submitted my name and birthday"
  Voter.stub!(:find_by_name_and_date_of_birth).and_return(nil)
end

Given /^I confirm my name and birthday$/ do
  @user.status = "pending_voter_info_confirmation"
  @user.process_yes
end

Given /^I enter my street address$/ do
  @user.status = "pending_address_line_1"
  @user.process_message("123 Main St.")
end

Given /^I have entered an address that is found$/ do
  @voter = Voter.new(Voter.default_attributes())
  Voter.stub!(:lookup!).and_return(@voter)
  Given "I enter my street address"
  And "I enter my city"
  And "I enter my zip"
end

Given /^I have entered an address that is not found$/ do
  @voter = Voter.new(Voter.default_attributes())
  Voter.stub!(:lookup!).and_return(nil)
  Given "I enter my street address"
  And "I enter my city"
  And "I enter my zip"
end

Given /^I confirm that my address is correct$/ do
  @user.status= "pending_user_entered_voter_address_confirmation"
  @user.process_message("yes")
end

When /^I enter my city$/ do
  @user.status = "pending_city"
  @user.process_message("Madison")
end

When /^I enter my zip$/ do
  @user.status = "pending_zip"
  @user.process_message("53798")
end

When /^I submit my birthday$/ do
  @user.process_message("6/12/1919")
end

When /^I confirm my voter info$/ do
  @user.status = "pending_voter_info_confirmation"
  @response = @user.process_message("yes")
end

Then /^I should be prompted to confirm my address$/ do
  @response.should =~ /You are currently registered/
end

Then /^I should be in a status of "([^"]*)"$/ do |arg1|
  @user.status.should == arg1
end

Then /^I should be prompted "([^"]*)"$/ do |arg1|
 @user.prompt.should =~ /#{arg1}/
end

Then /^I should be shown "([^"]*)"$/ do |arg1|
  @user.summary.should =~ /#{arg1}/
end
