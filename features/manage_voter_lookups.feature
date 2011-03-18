Feature: Manage voter_lookups
  In order to get voter information about users
  As the system
  I want to lookup voter records on voter public access website
  
  Scenario: Lookup voter who is registered 
    Given user "John Smith" exists at phone # "+15555551212"
    And voter "John Smith" is registered to vote
    And I have submitted my name and birthday correctly
    When I confirm my voter info for voter "John Smith"
    Then I should be prompted to confirm my address

  Scenario: Lookup voter who is not registered
    Given user "John Smith" exists at phone # "+15555551212"
    And voter "John Smith" is not registered to vote
    And I have submitted my name and birthday correctly
    When I confirm my voter info for voter "John Smith"
    Then I should be prompted "Have you voted in Wisconsin before"
