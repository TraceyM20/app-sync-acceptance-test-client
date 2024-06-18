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

import static nz.vts.nep.core.shared.component.api.domain.HttpStatusCode.ACCEPTED;
import static nz.vts.nep.core.shared.component.api.domain.HttpStatusCode.FORBIDDEN;
import static nz.vts.nep.core.shared.component.api.domain.HttpStatusCode.UNAUTHORIZED;
import static nz.vts.nep.template.EndpointsConfig.GATEWAY_API_KEY;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static shiver.me.timbers.data.random.RandomStrings.someAlphanumericString;
import static shiver.me.timbers.data.random.RandomStrings.someString;
import static shiver.me.timbers.data.random.RandomThings.someThing;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.github.tomakehurst.wiremock.http.HttpHeaders;

import nz.vts.nep.core.shared.component.ConfigurationStore;
import nz.vts.nep.core.shared.component.api.domain.ApiClientException;
import nz.vts.nep.template.EndpointsConfig;
import nz.vts.nep.template.authentication.CognitoAuthenticationToken;
import nz.vts.nep.template.holder.ApiClientExceptionHolder;
import nz.vts.nep.template.holder.ApiGatewayKeyHolder;
import nz.vts.nep.template.holder.AuthenticationTokenHolder;
import nz.vts.nep.template.holder.HttpHeaderHolder;

class AuthenticationStepTest {

    private ApiGatewayKeyHolder apiGatewayKeyHolder;
    private AuthenticationTokenHolder authenticationTokenHolder;
    private ConfigurationStore configurationStore;
    private CognitoAuthenticationToken cognitoAuthenticationToken;
    private ApiClientExceptionHolder apiClientExceptionHolder;
    private AuthenticationStep authenticationStep;
    private HttpHeaderHolder httpHeaderHolder;

    private final String apiKey = someString();
    private final String token = someString();

    @BeforeEach
    void setup() {
        this.apiGatewayKeyHolder = mock(ApiGatewayKeyHolder.class);
        this.authenticationTokenHolder = mock(AuthenticationTokenHolder.class);
        this.apiClientExceptionHolder = mock(ApiClientExceptionHolder.class);
        this.configurationStore = mock(ConfigurationStore.class);
        this.cognitoAuthenticationToken = mock(CognitoAuthenticationToken.class);
        this.httpHeaderHolder = mock(HttpHeaderHolder.class);
        this.authenticationStep = new AuthenticationStep(
                this.apiGatewayKeyHolder,
                this.authenticationTokenHolder,
                this.apiClientExceptionHolder,
                this.configurationStore,
                this.cognitoAuthenticationToken,
                this.httpHeaderHolder
        );
    }

    @Test
    void Can_validate_an_authorised_user_with_valid_client_credentials() {
        // Given
        given(this.configurationStore.getUnwrapped(EndpointsConfig.CLIENT_ID, String.class)).willReturn(someString());
        given(this.configurationStore.getUnwrapped(EndpointsConfig.CLIENT_SECRET, String.class)).willReturn(someString());

        // When
        this.authenticationStep.anAuthorisedUserWithValidClientCredentials();
    }

    @Test
    void Can_fail_to_validate_an_authorised_user_with_valid_client_credentials_with_missing_client_id() {
        // Given
        given(this.configurationStore.getUnwrapped(EndpointsConfig.CLIENT_ID, String.class)).willReturn("");
        given(this.configurationStore.getUnwrapped(EndpointsConfig.CLIENT_SECRET, String.class)).willReturn(someString());

        // When
        assertThrows(
            AssertionError.class,
            () -> this.authenticationStep.anAuthorisedUserWithValidClientCredentials()
        );
    }

    @Test
    void Can_fail_to_validate_an_authorised_user_with_valid_client_credentials_with_missing_client_secret() {
        // Given
        given(this.configurationStore.getUnwrapped(EndpointsConfig.CLIENT_ID, String.class)).willReturn(someString());
        given(this.configurationStore.getUnwrapped(EndpointsConfig.CLIENT_SECRET, String.class)).willReturn("");

        // When
        assertThrows(
            AssertionError.class,
            () -> this.authenticationStep.anAuthorisedUserWithValidClientCredentials()
        );
    }

    @Test
    void Can_make_call_to_the_authentication_token_issuer() {
        // Given
        final String token = someString();
        given(cognitoAuthenticationToken.accessToken()).willReturn(token);

        // When
        this.authenticationStep.aCallIsMadeToTheAuthenticationTokenIssuer();

        // Then
        then(this.authenticationTokenHolder).should().set(token);
    }

    @Test
    void Can_validate_an_authentication_token_is_returned_from_the_token_issuer() {
        // Given
        given(this.authenticationTokenHolder.get()).willReturn(someString());

        // When
        this.authenticationStep.anAuthenticationTokenShouldBeReturnedFromTheTokenIssuer();
    }

    @Test
    void Can_fail_to_validate_an_authentication_token_is_returned_from_the_token_issuer() {
        // Given
        given(this.authenticationTokenHolder.get()).willReturn("");

        // When
        assertThrows(
            AssertionError.class,
            () -> this.authenticationStep.anAuthenticationTokenShouldBeReturnedFromTheTokenIssuer()
        );
    }

    @Test
    void Can_set_an_authorised_user_with_valid_cred_and_api_key() {
        // Given
        given(this.configurationStore.getUnwrapped(GATEWAY_API_KEY, String.class)).willReturn(apiKey);
        given(this.cognitoAuthenticationToken.accessToken()).willReturn(token);

        // When
        this.authenticationStep.anAuthorisedUserWithValidCredentialsAndApiKey();

        // Then
        then(this.apiGatewayKeyHolder).should().set(apiKey);
        then(this.authenticationTokenHolder).should().set(token);
    }

    @Test
    void Can_set_an_authorised_user_with_invalid_credentials_and_valid_apiKey() {
        // Given
        given(this.configurationStore.getUnwrapped(GATEWAY_API_KEY, String.class)).willReturn(apiKey);

        // When
        this.authenticationStep.anAuthorisedUserWithInvalidCredentialsAndValidApiKey();

        // Then
        then(this.apiGatewayKeyHolder).should().set(apiKey);
        then(this.authenticationTokenHolder).should().set(anyString());
        then(this.cognitoAuthenticationToken).should(never()).accessToken();
    }

    @Test
    void Can_set_an_authorised_user_with_valid_credentials_and_invalid_apiKey() {
        // Given
        given(this.cognitoAuthenticationToken.accessToken()).willReturn(token);

        // When
        this.authenticationStep.anAuthorisedUserWithValidCredentialsAndInvalidApiKey();

        // Then
        then(this.apiGatewayKeyHolder).should().set(anyString());
        then(this.authenticationTokenHolder).should().set(token);
        then(this.configurationStore).should(never()).getUnwrapped(GATEWAY_API_KEY, String.class);
    }

    @Test
    void Can_validate_an_unauthorised_response_status_is_not_returned_from_the_API() {
        // Given
        final ApiClientException apiClientException = mock(ApiClientException.class);
        given(this.apiClientExceptionHolder.get()).willReturn(apiClientException);
        given(apiClientException.getStatusCode()).willReturn(someThing(200, 201, 400, 500));

        // When
        this.authenticationStep.anUnauthorisedResponseStatusShouldNotBeReturnedFromTheAPI();
    }

    @Test
    void Can_validate_an_unauthorised_response_status_is_not_returned_from_the_API_on_success() {
        final ApiClientException apiClientException = mock(ApiClientException.class);

        // Given
        given(this.apiClientExceptionHolder.get()).willReturn(apiClientException);
        given(apiClientException.getStatusCode()).willReturn(ACCEPTED);

        // When
        this.authenticationStep.anUnauthorisedResponseStatusShouldNotBeReturnedFromTheAPI();
    }

    @Test
    void Can_validate_an_unauthorised_response_status_is_not_returned_from_the_API_for_no_client_exception() {
        // Given
        given(this.apiClientExceptionHolder.get()).willReturn(null);

        // When
        this.authenticationStep.anUnauthorisedResponseStatusShouldNotBeReturnedFromTheAPI();
    }

    @Test
    void Can_fail_to_validate_an_unauthorised_response_status_is_not_returned_from_the_API() {
        // Given
        final ApiClientException apiClientException = mock(ApiClientException.class);
        given(this.apiClientExceptionHolder.get()).willReturn(apiClientException);
        given(apiClientException.getStatusCode()).willReturn(someThing(UNAUTHORIZED, FORBIDDEN));

        // When
        assertThrows(
            AssertionError.class,
            () -> this.authenticationStep.anUnauthorisedResponseStatusShouldNotBeReturnedFromTheAPI()
        );
    }

    @Test
    void Can_validate_an_unauthorised_response_status_is_returned_from_the_API() {
        // Given
        final ApiClientException apiClientException = mock(ApiClientException.class);
        given(this.apiClientExceptionHolder.get()).willReturn(apiClientException);
        given(apiClientException.getStatusCode()).willReturn(UNAUTHORIZED);

        // When
        this.authenticationStep.anUnauthorisedResponseStatusShouldBeReturnedFromTheAPI();
    }

    @Test
    void Can_fail_to_validate_an_unauthorised_response_status_is_returned_from_the_API() {
        // Given
        final ApiClientException apiClientException = mock(ApiClientException.class);
        given(this.apiClientExceptionHolder.get()).willReturn(apiClientException);
        given(apiClientException.getStatusCode()).willReturn(someThing(200, 201, 400, 403, 417, 500));

        // When
        assertThrows(
            AssertionError.class,
            () -> this.authenticationStep.anUnauthorisedResponseStatusShouldBeReturnedFromTheAPI()
        );
    }

    @Test
    void Can_validate_a_forbidden_response_status_is_returned_from_the_API() {
        // Given
        final ApiClientException apiClientException = mock(ApiClientException.class);
        given(this.apiClientExceptionHolder.get()).willReturn(apiClientException);
        given(apiClientException.getStatusCode()).willReturn(FORBIDDEN);

        // When
        this.authenticationStep.aForbiddenResponseStatusShouldBeReturnedFromTheAPI();
    }

    @Test
    void Can_fail_to_validate_a_forbidden_response_status_is_returned_from_the_API() {
        // Given
        final ApiClientException apiClientException = mock(ApiClientException.class);
        given(this.apiClientExceptionHolder.get()).willReturn(apiClientException);
        given(apiClientException.getStatusCode()).willReturn(someThing(200, 201, 400, 401, 417, 500));

        // When
        assertThrows(
            AssertionError.class,
            () -> this.authenticationStep.aForbiddenResponseStatusShouldBeReturnedFromTheAPI()
        );
    }

    @Test
    void Can_set_a_lambda_configuration_with_valid_device_data_service_api_key_is_configured() {
        // Given
        final String xApiKey = someAlphanumericString(1, 64);
        given(this.configurationStore.getUnwrapped(EndpointsConfig.DEVICE_DATA_STORE_API_KEY, String.class)).willReturn(xApiKey);

        // When
        this.authenticationStep.lambdaConfigurationWithValidDeviceDataServiceApiKey();

        // Then
        then(httpHeaderHolder).should().set(any(HttpHeaders.class));
    }
}
