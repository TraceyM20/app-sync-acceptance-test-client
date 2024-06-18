Feature: Service Configuration
  As Vector LTD,
  We want to all external and internal integrations secured as per the defined enterprise standards
  So that all information and security risks are addressed as per defined enterprise standards

  Scenario: A authorised person or system (User) with valid credentials should be able to obtain an authentication token
    Given An authorised user with valid client credentials
    When A call is made to the authentication token issuer
    Then An authentication token should be returned from the token issuer

  Scenario: A authorised person or system (User) with valid API key and authentication token (credentials) should be able to call a restricted API
    Given An authorised user with valid credentials and API key
    When a call is made to a restricted API endpoint
    Then An 'Unauthorised' or 'Forbidden' response status should not be returned from the API

  Scenario: A person or system (User) without valid credentials and with valid API key should not be able to call a restricted API
    Given An authorised user with invalid credentials and valid API key
    When a call is made to a restricted API endpoint
    Then An 'Unauthorised' response status should be returned from the API

  Scenario: A person or system (User) with valid credentials and without a valid API key should not be able to call a restricted API
    Given An authorised user with valid credentials and invalid API key
    When a call is made to a restricted API endpoint
    Then A 'Forbidden' response status should be returned from the API
