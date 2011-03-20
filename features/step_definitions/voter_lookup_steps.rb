Given /^I have submitted my first and last name$/ do
  #TODO: clean up users and sms voters here
  @user = User.create!(User.default_attributes())
  @sms_voter = @user.create_sms_voter(SmsVoter.default_attributes(:date_of_birth => nil))
  @sms_voter.status = "pending_date_of_birth"
end

Given /^I have submitted my name and birthday$/ do
  @user = User.create!(User.default_attributes())
  @sms_voter = @user.create_sms_voter(SmsVoter.default_attributes())
  @sms_voter.status = "pending_voter_info_confirmation"
end

Given /^I am a registered voter$/ do
  @voter_record = VoterRecord.new(VoterRecord.default_attributes())
  VoterRecord.stub!(:find_by_name_and_date_of_birth).and_return(@voter_record)
end

Given  /^I can't be found in the voter lookup system$/ do 
  Given "I am not a registered voter"
  And "I confirm my voter info"
end

Given /^I am not a registered voter$/ do
  Given "I have submitted my name and birthday"
  VoterRecord.stub!(:find_by_name_and_date_of_birth).and_return(nil)
end

Given /^I confirm my name and birthday$/ do
  @sms_voter.status = "pending_voter_info_confirmation"
  @sms_voter.process_yes
end

Given /^I enter my street address$/ do
  @sms_voter.status = "pending_address_line_1"
  @sms_voter.process_message("123 Main St.")
end

Given /^I have entered an address that is found$/ do
  @voter = VoterRecord.new(VoterRecord.default_attributes())
  VoterRecord.stub!(:lookup!).and_return(@voter)
  Given "I enter my street address"
  And "I enter my city"
  And "I enter my zip"
end

Given /^I have entered an address that is not found$/ do
  @voter = VoterRecord.new(VoterRecord.default_attributes())
  VoterRecord.stub!(:lookup!).and_return(nil)
  Given "I enter my street address"
  And "I enter my city"
  And "I enter my zip"
end

Given /^I confirm that my address is correct$/ do
  @sms_voter.status= "pending_user_entered_voter_address_confirmation"
  @sms_voter.process_message("yes")
end

When /^I enter my city$/ do
  @sms_voter.status = "pending_city"
  @sms_voter.process_message("Madison")
end

When /^I enter my zip$/ do
  @sms_voter.status = "pending_zip"
  @sms_voter.process_message("53798")
end

When /^I submit my birthday$/ do
  @sms_voter.process_message("6/12/1919")
end

When /^I confirm my voter info$/ do
  @sms_voter.status = "pending_voter_info_confirmation"
  @response = @sms_voter.process_message("yes")
end

Then /^I should be prompted to confirm my address$/ do
  @response.should =~ /You are currently registered/
end

Then /^I should be in a status of "([^"]*)"$/ do |arg1|
  @sms_voter.status.should == arg1
end

Then /^I should be prompted "([^"]*)"$/ do |arg1|
 @sms_voter.prompt.should =~ /#{arg1}/
end

Then /^I should be shown "([^"]*)"$/ do |arg1|
  @sms_voter.summary.should =~ /#{arg1}/
end
