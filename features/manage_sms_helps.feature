Feature: Manage sms help conversations
  In order to get answers to issues when using the sms system
  As a potential voter
  I want to have a SMS help system

  Scenario: User enters help conversation by texting "help"
    Given I have submitted my first and last name 
    When I text "help"
    Then I should be prompted "Please describe the issue"

  Scenario: User is flagged as needing help when texts "help"
    Given I have submitted my first and last name
    When I text "help"
    Then my user should have status "needs_help"

  Scenario: User enters description of issue
    Given I have submitted my first and last name
    And I am in the help system
    And I have been prompted to describe my issue
    When I text "I'm really confused"
    Then I should be shown "Thanks for your input"

  Scenario: User can start over at end of help
    Given I have submitted my first and last name
    And I am in the help system
    And I make it to the next action prompt
    When I text "start over"
    Then I should be prompted "Ok, What is your full first name?"

  Scenario: User can re-enter help at end of help
    Given I have submitted my first and last name
    And I am in the help system
    And I make it to the next action prompt
    When I text "help"
    Then I should be prompted "Please describe the issue"

