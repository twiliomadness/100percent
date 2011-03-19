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

Given /^I am not a registered voter$/ do
  Given "I have submitted my name and birthday"
  Voter.stub!(:find_by_name_and_date_of_birth).and_return(nil)
end

Given /^I confirm my name and birthday correctly$/ do
  @user.status = "pending_voter_info_confirmation"
  @user.process_yes
end

When /^I submit my birthday$/ do
  @user.process_message("6/12/1919")
end

When /^I confirm I have voted in the past$/ do
  @user.status = "pending_voter_history_confirmation"
  @user.confirmed_voting_history
end

When /^I confirm my voter info$/ do
  @user.status = "pending_voter_info_confirmation"
  @response = @user.process_message("yes")
end

Then /^I should be prompted to confirm my address$/ do
  @response.should =~ /We have #{@user.first_name} #{@user.last_name}/
end

Then /^I should be in a status of "([^"]*)"$/ do |arg1|
  @user.status.should == arg1
end

Then /^I should be prompted "([^"]*)"$/ do |arg1|
  @user.prompt.should =~ /#{arg1}/
end



