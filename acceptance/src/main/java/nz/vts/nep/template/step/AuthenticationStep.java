/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template.step;

import static nz.vts.nep.core.shared.component.api.domain.HttpStatusCode.FORBIDDEN;
import static nz.vts.nep.core.shared.component.api.domain.HttpStatusCode.UNAUTHORIZED;
import static nz.vts.nep.template.EndpointsConfig.GATEWAY_API_KEY;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.isEmptyString;
import static org.hamcrest.Matchers.not;
import static shiver.me.timbers.data.random.RandomStrings.someAlphanumericString;

import java.util.Arrays;

import com.github.tomakehurst.wiremock.http.HttpHeader;
import com.github.tomakehurst.wiremock.http.HttpHeaders;

import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

import nz.vts.nep.core.shared.component.ConfigurationStore;
import nz.vts.nep.core.shared.component.api.domain.ApiClientException;
import nz.vts.nep.template.EndpointsConfig;
import nz.vts.nep.template.authentication.CognitoAuthenticationToken;
import nz.vts.nep.template.holder.ApiClientExceptionHolder;
import nz.vts.nep.template.holder.ApiGatewayKeyHolder;
import nz.vts.nep.template.holder.AuthenticationTokenHolder;
import nz.vts.nep.template.holder.HttpHeaderHolder;

public class AuthenticationStep {

    private static final String X_API_KEY = "x-api-key";
    private final ApiGatewayKeyHolder apiGatewayKeyHolder;
    private final AuthenticationTokenHolder authenticationTokenHolder;
    private final ApiClientExceptionHolder apiClientExceptionHolder;
    private final ConfigurationStore configurationStore;
    private final CognitoAuthenticationToken cognitoAuthenticationToken;
    private final HttpHeaderHolder httpHeaderHolder;

    public AuthenticationStep(
            final ApiGatewayKeyHolder apiGatewayKeyHolder,
            final AuthenticationTokenHolder authenticationTokenHolder,
            final ApiClientExceptionHolder apiClientExceptionHolder,
            final ConfigurationStore configurationStore,
            final CognitoAuthenticationToken cognitoAuthenticationToken,
            final HttpHeaderHolder httpHeaderHolder
    ) {
        this.apiGatewayKeyHolder = apiGatewayKeyHolder;
        this.authenticationTokenHolder = authenticationTokenHolder;
        this.apiClientExceptionHolder = apiClientExceptionHolder;
        this.configurationStore = configurationStore;
        this.cognitoAuthenticationToken = cognitoAuthenticationToken;
        this.httpHeaderHolder = httpHeaderHolder;
    }

    @Given("An authorised user with valid client credentials")
    public void anAuthorisedUserWithValidClientCredentials() {
        assertThat(this.configurationStore.getUnwrapped(EndpointsConfig.CLIENT_ID, String.class), not(isEmptyString()));
        assertThat(this.configurationStore.getUnwrapped(EndpointsConfig.CLIENT_SECRET, String.class), not(isEmptyString()));
    }

    @Given("An authorised user with valid credentials and API key")
    public void anAuthorisedUserWithValidCredentialsAndApiKey() {
        setValidApiKey();
        setValidAuthenticationToken();
    }

    @Given("An authorised user with invalid credentials and valid API key")
    public void anAuthorisedUserWithInvalidCredentialsAndValidApiKey() {
        setValidApiKey();
        this.authenticationTokenHolder.set(someAlphanumericString(128));
    }

    @Given("An authorised user with valid credentials and invalid API key")
    public void anAuthorisedUserWithValidCredentialsAndInvalidApiKey() {
        this.apiGatewayKeyHolder.set(someAlphanumericString(32));
        setValidAuthenticationToken();
    }

    @When("A call is made to the authentication token issuer")
    public void aCallIsMadeToTheAuthenticationTokenIssuer() {
        setValidAuthenticationToken();
    }

    @Then("An authentication token should be returned from the token issuer")
    public void anAuthenticationTokenShouldBeReturnedFromTheTokenIssuer() {
        assertThat(this.authenticationTokenHolder.get(), not(isEmptyString()));
    }

    @Then("An 'Unauthorised' or 'Forbidden' response status should not be returned from the API")
    public void anUnauthorisedResponseStatusShouldNotBeReturnedFromTheAPI() {
        final ApiClientException apiClientException = this.apiClientExceptionHolder.get();
        boolean hasAuthError = (apiClientException != null)
                && Arrays.asList(UNAUTHORIZED, FORBIDDEN).contains(apiClientException.getStatusCode());
        assertThat(hasAuthError, is(false));
    }

    @Then("An 'Unauthorised' response status should be returned from the API")
    public void anUnauthorisedResponseStatusShouldBeReturnedFromTheAPI() {
        final ApiClientException apiClientException = this.apiClientExceptionHolder.get();

        assertThat(apiClientException, notNullValue());
        assertThat(apiClientException.getStatusCode(), is(UNAUTHORIZED));
    }

    @Then("A 'Forbidden' response status should be returned from the API")
    public void aForbiddenResponseStatusShouldBeReturnedFromTheAPI() {
        assertThat(this.apiClientExceptionHolder.get().getStatusCode(), is(FORBIDDEN));
    }

    @And("lambda configuration with valid device data service API key")
    public void lambdaConfigurationWithValidDeviceDataServiceApiKey() {
        final String apiKey = this.configurationStore.getUnwrapped(EndpointsConfig.DEVICE_DATA_STORE_API_KEY, String.class);
        httpHeaderHolder.set(new HttpHeaders(new HttpHeader(X_API_KEY, apiKey)));
    }

    private void setValidApiKey() {
        final String apiKey = this.configurationStore.getUnwrapped(GATEWAY_API_KEY, String.class);
        this.apiGatewayKeyHolder.set(apiKey);
    }

    private void setValidAuthenticationToken() {
        final String token = cognitoAuthenticationToken.accessToken();
        this.authenticationTokenHolder.set(token);
    }
}
