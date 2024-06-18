/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template.authentication;

import static org.hamcrest.CoreMatchers.instanceOf;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.junit.Assert.fail;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static shiver.me.timbers.data.random.RandomStrings.someAlphanumericString;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.function.Consumer;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import nz.vts.nep.core.shared.cognito.api.CognitoApi;
import nz.vts.nep.core.shared.cognito.model.CreateTokenResponse;
import nz.vts.nep.core.shared.component.api.domain.ApiClientException;

class CognitoAuthenticationTokenTest {
    private static final String CLIENT_CREDENTIALS = "client_credentials";

    private CognitoApi cognitoApi;
    private String clientId;
    private String clientSecret;
    private CognitoAuthenticationToken cognitoAuthenticationToken;

    @BeforeEach
    void setUp() {
        this.cognitoApi = mock(CognitoApi.class);
        this.clientId = someAlphanumericString(1, 64);
        this.clientSecret = someAlphanumericString(1, 64);

        this.cognitoAuthenticationToken = new CognitoAuthenticationToken(
                this.cognitoApi,
                this.clientId,
                this.clientSecret
        );
    }

    @Test
    void Can_retrieve_token_request_uncached_token() {
        // Given
        final CreateTokenResponse cognitoToken = mock(CreateTokenResponse.class);
        final String accessToken = someAlphanumericString(1, 64);

        given(this.cognitoApi.createToken(CLIENT_CREDENTIALS, this.clientId, this.clientSecret))
                .willReturn(cognitoToken);
        given(cognitoToken.getAccessToken()).willReturn(accessToken);
        given(cognitoToken.getExpiresIn()).willReturn(300L); // 5 minutes

        // When
        final String actual = this.cognitoAuthenticationToken.accessToken();

        // Then
        assertThat(actual, is(accessToken));
    }

    @Test
    void Can_retrieve_token_using_cached_token() {
        // Given
        final CreateTokenResponse cognitoToken = mock(CreateTokenResponse.class);
        final String accessToken = someAlphanumericString(1, 64);

        given(this.cognitoApi.createToken(CLIENT_CREDENTIALS, this.clientId, this.clientSecret))
                .willReturn(cognitoToken);
        given(cognitoToken.getAccessToken()).willReturn(accessToken);
        given(cognitoToken.getExpiresIn()).willReturn(300L); // 5 minutes

        // When
        final String firstToken = this.cognitoAuthenticationToken.accessToken();
        this.delayNextOperationFor(5);
        final String secondToken = this.cognitoAuthenticationToken.accessToken();

        // Then
        then(this.cognitoApi).should(times(1))
                .createToken(CLIENT_CREDENTIALS, this.clientId, this.clientSecret);
        assertThat(firstToken, is(accessToken));
        assertThat(secondToken, is(accessToken));
    }

    @Test
    void Can_retrieve_token_with_expired_cached_token() {
        // Given
        final CreateTokenResponse firstCognitoToken = mock(CreateTokenResponse.class);
        final CreateTokenResponse secondCognitoToken = mock(CreateTokenResponse.class);
        final String firstAccessToken = someAlphanumericString(1, 64);
        final String secondAccessToken = someAlphanumericString(1, 64);

        given(this.cognitoApi.createToken(CLIENT_CREDENTIALS, this.clientId, this.clientSecret))
                .willReturn(firstCognitoToken)
                .willReturn(secondCognitoToken);
        given(firstCognitoToken.getAccessToken()).willReturn(firstAccessToken);
        given(firstCognitoToken.getExpiresIn()).willReturn(1L); // 1 second
        given(secondCognitoToken.getAccessToken()).willReturn(secondAccessToken);
        given(secondCognitoToken.getExpiresIn()).willReturn(1L); // 1 second

        // When
        final String firstToken = this.cognitoAuthenticationToken.accessToken();
        this.delayNextOperationFor(3);
        final String secondToken = this.cognitoAuthenticationToken.accessToken();

        // Then
        then(this.cognitoApi).should(times(2))
                .createToken(CLIENT_CREDENTIALS, this.clientId, this.clientSecret);
        assertThat(firstToken, is(firstAccessToken));
        assertThat(secondToken, is(secondAccessToken));
    }

    @Test
    void Can_retrieve_token_after_exception() {
        // Given
        final CreateTokenResponse firstCognitoToken = mock(CreateTokenResponse.class);
        final CreateTokenResponse secondCognitoToken = mock(CreateTokenResponse.class);
        final String firstAccessToken = someAlphanumericString(1, 64);
        final String secondAccessToken = someAlphanumericString(1, 64);

        given(this.cognitoApi.createToken(CLIENT_CREDENTIALS, this.clientId, this.clientSecret))
                .willReturn(firstCognitoToken)
                .willThrow(new ApiClientException("Unit test"))
                .willReturn(secondCognitoToken);
        given(firstCognitoToken.getAccessToken()).willReturn(firstAccessToken);
        given(firstCognitoToken.getExpiresIn()).willReturn(1L); // 1 second
        given(secondCognitoToken.getAccessToken()).willReturn(secondAccessToken);
        given(secondCognitoToken.getExpiresIn()).willReturn(1L); // 1 second

        // When
        final String firstToken = this.cognitoAuthenticationToken.accessToken();
        this.delayNextOperationFor(3);
        this.assertFailsWith(
            ApiClientException.class,
            (nothing) -> this.cognitoAuthenticationToken.accessToken()
        );
        this.delayNextOperationFor(2);
        final String secondToken = this.cognitoAuthenticationToken.accessToken();

        // Then
        then(this.cognitoApi).should(times(3))
                .createToken(CLIENT_CREDENTIALS, this.clientId, this.clientSecret);
        assertThat(firstToken, is(firstAccessToken));
        assertThat(secondToken, is(secondAccessToken));
    }

    @Test
    void Can_retrieve_token_raise_exception_from_cognito_api() {
        // Given
        final String message = "Unit test";

        given(this.cognitoApi.createToken(CLIENT_CREDENTIALS, this.clientId, this.clientSecret))
                .willThrow(new ApiClientException(message));

        // When
        final ApiClientException apiClientException =
                assertThrows(ApiClientException.class, () -> this.cognitoAuthenticationToken.accessToken());

        // Then
        assertThat(apiClientException.getMessage(), is(message));
    }

    @SuppressWarnings("ResultOfMethodCallIgnored")
    private void delayNextOperationFor(
            final Integer seconds
    ) {
        try {
            final CountDownLatch countDownLatch = new CountDownLatch(1);
            countDownLatch.await(seconds, TimeUnit.SECONDS);
        } catch (final InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException(exception);
        }
    }

    @SuppressWarnings("SameParameterValue")
    private void assertFailsWith(
            final Class<? extends Exception> expectedException,
            final Consumer<Void> methodCall
    ) {
        try {
            methodCall.accept(null);
            fail();
        } catch (final Exception exception) {
            assertThat(exception, instanceOf(expectedException));
        }
    }
}
