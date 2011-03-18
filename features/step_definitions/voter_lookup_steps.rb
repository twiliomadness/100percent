Given /^voter "([^"]*)" exists at phone \# "([^"]+)"$/ do |voter_name, phone_number|
  @voter = Voter.new(Voter.default_attributes())
  Voter.stub!(:find_by_name_and_date_of_birth).and_return(@voter)
end

Given /^voter "([^"]*)" is registered to vote$/ do |arg1|
    pending # express the regexp above with the code you wish you had
end

When /^I confirm my voter info for voter "([^"]*)"$/ do |arg1|
    pending # express the regexp above with the code you wish you had
end

Then /^I should be prompted to confirm my address$/ do
    pending # express the regexp above with the code you wish you had
end

