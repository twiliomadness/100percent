Feature: Manage voter_lookups
  In order to get voter information about users
  As the system
  I want to lookup voter records on voter public access website
 
  Scenario: Prompt new user for first name

  Scenario: Prompt for last name

  Scenario: Prompt for birthday

  Scenario: Confirm voter info
    Given I am a registered voter
    Given I have submitted my first and last name
    When I submit my birthday
    Then I should be shown "You are currently registered at"

  Scenario: Malformed voter history conf shows custom message
    Given I am not a registered voter
    Given I have submitted my name and birthday
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
    Then I should be prompted "Have you voted in Wisconsin before?"

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
    And I have entered an address that is found
    Then I should be shown "You are currently registered at"

  Scenario: Registered voter confirms info
    Given I am a registered voter
    Given I have submitted my name and birthday
    Then I should be shown "You are currently registered at:\n\n123 MAIN ST.\nMADISON 53703"

  Scenario: Address lookup failed
    Given I am a registered voter
    And I have submitted my name and birthday
    And I have entered an address that is not found
    Then I should be prompted "Is this your current address?"

  Scenario: Address lookup failed, and user confirms bad address
    Given I am not a registered voter
    And I have submitted my name and birthday
    And I have entered an address that is not found
    And I text "yes"
    Then I should be shown "We can't find your address in the database. So, a volunteer will contact you shortly to help out."

  Scenario: Malformed answer to yes/no question raises validation
    Given I am not a registered voter
    And I have submitted my name and birthday
    When I text "This is not recognized"
    Then I should be shown "Sorry"

  Scenario: Malformed answer to yes/no causes question to be repeated
    Given I am not a registered voter
    And I have submitted my name and birthday
    When I text "This is not recognized"
    Then I should be prompted "Have you voted in Wisconsin before?"

  Scenario: Blank answer to yes/no causes question to be repeated
    Given I am not a registered voter
    And I have submitted my name and birthday
    When I text ""
    Then I should be shown "Sorry"

  Scenario: Blank answer to text question raises validation error
    Given I am not a registered voter
    And I have submitted my name and birthday
    And I enter my street address
    When I text ""
    Then I should be shown "Sorry"

  Scenario: Blank anwser to text question causes question to be repeated
    Given I am not a registered voter
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
