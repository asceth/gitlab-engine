Feature: Browse commits
  Background: 
    Given I signin as a user
    And I own project "Shop"
    Given I visit project commits page

  Scenario: I browse commits list for master branch
    Then I see project commits

  Scenario: I browse atom feed of commits list for master branch
    Given I click atom feed link
    Then I see commits atom feed

  Scenario: I browse commit from list
    Given I click on commit link
    Then I see commit info

  Scenario: I compare refs
    Given I visit compare refs page
    And I fill compare fields with refs
    And I see compared refs 

