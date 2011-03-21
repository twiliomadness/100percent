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

  Scenario: Prompt for address if voter confirms information
    Given I have submitted my name and birthday
    And I am not a registered voter
    And I confirm my name and birthday
    Then I should be prompted "What is your street address?"

  Scenario: Propmpt for city after user enters address
    Given I have submitted my name and birthday
    When I enter my street address
    Then I should be prompted "City?"

  Scenario: Prompt for zip after user enters city
    Given I have submitted my name and birthday
    When I enter my street address
    And I enter my city
    Then I should be prompted "Zip?"

  Scenario: Address lookup succeeded
    Given I have submitted my name and birthday
    And I have entered an address that is found
    Then I should be shown "You are registered to vote at: GroundZero, 123 Main, Anywhere"

  Scenario: Address lookup failed
    Given I have submitted my name and birthday
    And I have entered an address that is not found
    Then I should be prompted "Is this your current address"

  Scenario: Address lookup failed, and user confirms bad address
    Given I have submitted my name and birthday
    And I have entered an address that is not found
    And I confirm that my address is correct
    Then I should be shown "A volunteer will contact you shortly"



