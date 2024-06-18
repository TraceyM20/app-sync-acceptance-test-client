Feature: the HelloHandler retrieves the parameter from request and involves it in the returned message

  Background:
    Given An authorised user with valid credentials and API key

  Scenario: a name given and a greeting is returned by HelloHandler
    Given An introduction of a person with a name
    When a greeting is sought
    Then the greeting is to the named person
