Feature: the health endpoint returns the health status

  Scenario: a call is made to the health apigw endpoint
    Given An authorised user with invalid credentials and valid API key
    When a health check call is made
    Then the response indicates good health

  Scenario: a call is made to the secure health apigw endpoint
    Given An authorised user with valid credentials and API key
    When a secure health check call is made
    Then the response indicates good health
