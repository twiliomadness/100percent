Feature: Manage voter_lookups
  In order to get voter information about users
  As the system
  I want to lookup voter records on voter public access website
 
  Scenario: Prompt new user for first name

  Scenario: Prompt for last name

  Scenario: Prompt for birthday

  Scenario: Confirm voter info
    Given I have submitted my first and last name
    When I submit my birthday
    Then I should be prompted "Is this correct?" 

 Scenario: Lookup voter who is registered 
    Given I have submitted my name and birthday
    And I am a registered voter
    When I confirm my voter info
    Then I should be prompted to confirm my address

  Scenario: Let voter know we'll contact them if no voter record exists
    Given I have submitted my name and birthday
    And I am not a registered voter
    And I confirm I have voted in the past
    When I confirm my voter info
    Then I should be prompted "One of our volunteers will contact you"

  Scenario: Verify voter info when user has voted
    Given I have submitted my name and birthday
    And I am not a registered voter
    When I confirm I have voted in the past
    Then I should be prompted "Please verify your record"


