Given /^I text "([^"]*)"$/ do |arg1|
  @sms_response = @sms_voter.process_message(arg1)
end

Given /^I am prompted with next options$/ do
  @sms_voter.transition_help
end

Given /^I am prompted to choose my next action$/ do
  @sms_voter.transition_help
end

Given /^I make it to the next action prompt$/ do
    And "I have been prompted to describe my issue"
    And "I text \"i'm confused\""
    And "I am prompted to choose my next action"
end

When /^I am in the help system$/ do
  @sms_voter.help_request_conversation
end

When /^I have been prompted to describe my issue$/ do
  @sms_voter.help_status = "pending_issue_description"
end

Then /^my user should have status "([^"]*)"$/ do |arg1|
  @sms_voter.user.status.should == arg1
end


