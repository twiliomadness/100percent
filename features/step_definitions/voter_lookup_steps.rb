Given /^I have submitted my first and last name$/ do
  @user ||= User.create!(User.default_attributes())
  @sms_voter ||= @user.create_sms_voter(:phone_number => @user.phone_number)
  User.stub!(:find_or_create_by_phone_number).and_return(@user)
  post_text "hi"
  post_text "John"
  post_text "Smith"
end

Given /^I have submitted my name and birthday$/ do
  Given "I have submitted my first and last name"
  post_text "6/13/1987"
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
  VoterRecord.stub!(:find_by_name_and_date_of_birth).and_return(nil)
end

Given /^I confirm my name and birthday$/ do
  @sms_voter.status = "pending_voter_info_confirmation"
  post_text ("yes")
end

Given /^I enter my street address$/ do
  @sms_voter.status = "pending_address_line_1"
  @sms_voter.fail_message = nil
  post_text("123 Main St.")
end

Given /^I have entered an address that is found for polling place "([^"]*)"$/ do |polling_place_name|
  @polling_place = PollingPlace.new(:location_name => "GroundZero", :address => "123 Main", :city => "Anywhere")
  PollingPlace.stub!(:get_polling_place).and_return(@polling_place)
  @sms_voter.stub!(:polling_place).and_return(@polling_place)
  @sms_voter.stub!(:update_voter_polling_place_clerk).and_return(true)
  @sms_voter.stub!(:happy_path_message_one).and_return(polling_place_name)
  @sms_voter.stub!(:happy_path_message_three).and_return("Happy Path 3")
  Given "I enter my street address"
  post_text "Madison"
  post_text "53719"
end

Given /^I have entered an address that is not found$/ do
 VoterRecord.stub!(:get_address_details_page).and_return(nil)
  Given "I enter my street address"
  post_text "Madison"
  post_text "53703"
end

Given /^I text "([^"]*)"$/ do |arg1|
  unless @user
    @user = User.new
    @user.save(:validate => false)
  end
  @sms_voter ||= @user.create_sms_voter(:phone_number => @user.phone_number)
  post_text arg1
end

When /^I enter my city$/ do
  @sms_voter.status = "pending_city"
  post_text("Madison")
end

When /^I enter my zip$/ do
  @sms_voter.status = "pending_zip"
  post_text("53798")
end

When /^I submit my birthday$/ do
  @sms_voter.status = "pending_date_of_birth"
  post_text("6/12/1919")
end

When /^I confirm my voter info$/ do
  @sms_voter.status = "pending_voter_info_confirmation"
  post_text("yes")
end

Then /^I should be prompted to confirm my address$/ do
  @sms_voter.last_summary.should =~ /You are currently registered/
end

Then /^I should be in a status of "([^"]*)"$/ do |arg1|
  @sms_voter.status.should == arg1
end

Then /^I should be prompted "([^"]*)"$/ do |arg1|
  OutgoingMessage.last.text =~ /arg1/
end

Then /^I should be shown "([^"]*)"$/ do |arg1|
  @sms_voter.outgoing_messages.last.text.should =~ /#{arg1}/
end

Then /^I should receive texts:$/ do |table|
 messages = OutgoingMessage.all.collect{|m| m.text}
  table.raw.each do |text_content|
   unless messages.collect{|m| m =~ /#{text_content[0]}/ ? true : false}.include? true
     messages.should include text_content[0]
   end
 end
end

Then /^I should receive text "([^"]*)"$/ do |arg1|
  messages = OutgoingMessage.all.collect{|m| m.text}
  
  unless messages.collect{|m| m =~ /arg1/ ? true : false}.include?(true)
    messages.should include arg1
  end
end


def post_text(text_message) 
  get(sms_request_path, :From => @user.phone_number, :Body => text_message)
end


