Feature: Authorize users against Facebook API
  In order to make it easy to use the app
  As a Facebook user
  I want to be able to authenticate using my Facebook account

  Scenario: Create a new user during Facebook auth
    Given I authorize with Facebook as "Bob Bobber"
    Then I should be logged into the app

  Scenario: New facebook users gets Birthday added to account
    Given I authorize with Facebook as "Bob Bobber"
    Then User "Bob Bobber" should have birthday set

  Scenario: Login an existing user with Facebook auth


