Given /^user "([^"]*)" exists at phone \# "([^"]+)"$/ do |voter_name, phone_number|
  @user = User.create!(User.default_attributes())
end

Given /^voter "([^"]*)" is registered to vote$/ do |arg1|
  @voter = Voter.new(Voter.default_attributes())
  Voter.stub!(:find_by_name_and_date_of_birth).and_return(@voter)
end

Given /^I have submitted my name and birthday correctly$/ do
  @user.status = "pending_voter_info_confirmation"
end

When /^I confirm my voter info for voter "([^"]*)"$/ do |arg1|
  @response = @user.process_message("yes")
end

Then /^I should be prompted to confirm my address$/ do
  @response.should =~ /We have/
end

Then /^voter "([^"]*)" is not registered to vote$/ do |arg1|
  Voter.stub!(:find_by_name_and_date_of_birth).and_return(nil)
end

Then /^I should be sent to a status of "([^"]*)"$/ do |arg1|
  @user.status.should == "welcome"
end

Then /^I should be prompted "([^"]*)"$/ do |arg1|
  @user.prompt =~ /arg1/
end

When /^I say that I have voted in Wisconsin before$/ do
  @response = @user.process_message("yes")
end
