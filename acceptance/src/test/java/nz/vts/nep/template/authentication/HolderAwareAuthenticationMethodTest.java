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

import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;
import static org.mockito.Mockito.mock;
import static shiver.me.timbers.data.random.RandomStrings.someAlphanumericString;

import org.apache.hc.core5.http.HttpRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationContext;

import nz.vts.nep.template.holder.ApiGatewayKeyHolder;
import nz.vts.nep.template.holder.AuthenticationTokenHolder;

class HolderAwareAuthenticationMethodTest {

    private ApplicationContext applicationContext;
    private HolderAwareAuthenticationMethod method;

    @BeforeEach
    void setUp() {
        this.applicationContext = mock(ApplicationContext.class);
        this.method = new HolderAwareAuthenticationMethod();
        this.method.setApplicationContext(this.applicationContext);
    }

    @Test
    void Can_apply_authentication_headers() {
        // Given
        final HttpRequest httpRequest = mock(HttpRequest.class);
        final String token = someAlphanumericString(1, 64);
        final String apikey = someAlphanumericString(1, 64);
        final AuthenticationTokenHolder authenticationTokenHolder = mock(AuthenticationTokenHolder.class);
        final ApiGatewayKeyHolder apiGatewayKeyHolder = mock(ApiGatewayKeyHolder.class);

        given(this.applicationContext.getBean(AuthenticationTokenHolder.class)).willReturn(authenticationTokenHolder);
        given(this.applicationContext.getBean(ApiGatewayKeyHolder.class)).willReturn(apiGatewayKeyHolder);
        given(authenticationTokenHolder.get()).willReturn(token);
        given(apiGatewayKeyHolder.get()).willReturn(apikey);

        // When
        this.method.applyTo(httpRequest);

        // Then
        then(httpRequest).should().addHeader("x-api-key", apikey);
        then(httpRequest).should().addHeader("Authorization", String.format("Bearer %s", token));
    }
}
