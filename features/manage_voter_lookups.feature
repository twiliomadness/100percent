Feature: Manage voter_lookups
  In order to get voter information about users
  As the system
  I want to lookup voter records on voter public access website
 
  Scenario: Prompt new user for first name

  Scenario: Prompt for last name

  Scenario: Prompt for birthday

  Scenario: New users should see a welcome message
    Given I am a registered voter
    When I text "Vote"
    Then I should receive texts:
    |Welcome|
    |What|

  Scenario: Confirm voter info
    Given I am a registered voter
    And I have submitted my first and last name
    When I submit my birthday
    Then I should be shown "You are currently registered at"

  Scenario: Malformed voter history conf shows custom message
    Given I am not a registered voter
    And I have submitted my name and birthday
    When I text "This is not valid"
    Then I should be shown "Sorry, I didn't understand that."

  Scenario: Confirm voter has voting history if lookup fails
    Given I am not a registered voter
    And I have submitted my name and birthday
    Then I should be prompted "Have you voted in Wisconsin before?"

  Scenario: Start over if user confirms voting history
    Given I am not a registered voter
    And I have submitted my name and birthday
    And I text "yes"
    Then I should be prompted "What is your full first name"

  Scenario: Lookup address if voter has no history
    Given I am not a registered voter
    And I have submitted my name and birthday
    And I text "no"
    Then I should be prompted "What is your street address"

  Scenario: Prompt for address if user confirms no voting history
    Given I am not a registered voter
    And I have submitted my name and birthday
    And I text "no"
    Then I should be prompted "What is your street address?"

  Scenario: Prompt for city after user enters address
    Given I am not a registered voter
    And I have submitted my name and birthday
    When I enter my street address
    Then I should be prompted "City?"

  Scenario: Prompt for zip after user enters city
    Given I am not a registered voter
    And I have submitted my name and birthday
    When I enter my street address
    And I enter my city
    Then I should be prompted "Zip?"

  Scenario: Show polling place info if address lookup is success
    Given I am not a registered voter
    And I have submitted my name and birthday
    And I have entered an address that is found for polling place "Poll 1"
    Then I should receive text "Poll 1"

  Scenario: Registered voter confirms info
    Given I am a registered voter
    Given I have submitted my name and birthday
    Then I should be shown "You are currently registered at:\n\n123 Main St., Madison"

  Scenario: Address lookup failed
    Given I am a registered voter
    And I have submitted my name and birthday
    And I have entered an address that is not found
    Then I should be prompted "What is your street address?"

  Scenario: Address lookup fails gets custom response
    Given I am not a registered voter
    And I have submitted my name and birthday
    And I have entered an address that is not found
    Then I should receive texts:
    |We couldn't find a record for you.\n\nHave you voted in Wisconsin before?|
    |Next step is to determine where you vote.\n\nWhat is your street address?|

  Scenario: Malformed answer to yes/no question raises validation
    Given I am a registered voter
    And I have submitted my name and birthday
    When I text "This is not recognized"
    Then I should be shown "Sorry"

  Scenario: Malformed answer to yes/no causes question to be repeated
    Given I am not a registered voter
    And I have submitted my name and birthday
    When I text "This is not recognized"
    Then I should be prompted "Have you voted in Wisconsin before?"

  Scenario: Blank answer to yes/no causes question to be repeated
    Given I am a registered voter
    And I have submitted my name and birthday
    When I text ""
    Then I should be shown "Sorry"

  Scenario: Blank answer to text question raises validation error
    Given I am a registered voter
    And I have submitted my name and birthday
    When I text ""
    Then I should be shown "Sorry"

  Scenario: Blank answer to text question causes question to be repeated
    Given I am a registered voter
    And I have submitted my name and birthday
    And I enter my street address
    When I text ""
    Then I should be prompted "City?"

  Scenario: Malformed date causes validation error
    Given I am not a registered voter
    And I have submitted my first and last name
    And I text "not a valid date"
    Then I should be shown "Sorry"

  Scenario: Malformed date causes question to be repeated
    Given I am not a registered voter
    And I have submitted my first and last name
    And I text "not a valid date"
    Then I should be prompted "What is your date of birth?"

  Scenario: Sending stop halts the system
    Given I have started the voter lookup conversation
    When I text "stop"
    Then I should not receive a message

  Scenario: In the stopped state, the system only responds to "help", "reset", and "start over" 
    Given I have stopped the voter lookup conversation
    When I text any of the following
    | x    |
    | vote |
    Then I should not receive a message
    When I text any of the following
    | help       |
    | reset      |
    | start over |
    Then I should receive a message
