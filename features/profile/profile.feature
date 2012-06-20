Feature: Profile
  Background: 
    Given I signin as a user

  Scenario: I look at my profile
    Given I visit profile page
    Then I should see my profile info

  Scenario: I change my password
    Given I visit profile password page
    Then I change my password
    And I should be redirected to sign in page

  Scenario: I reset my token
    Given I visit profile token page
    Then I reset my token
    And I should see new token

