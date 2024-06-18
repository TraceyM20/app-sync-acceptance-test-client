/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template.factory;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.notNullValue;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.github.tomakehurst.wiremock.http.HttpHeaders;

class AuthorizationHttpHeadersFactoryTest {

    private AuthorizationHttpHeadersFactory factory;

    @BeforeEach
    void setup() {
        factory = new AuthorizationHttpHeadersFactory();
    }

    @Test
    void Can_create_authorization_http_headers() {
        // When
        final HttpHeaders actual = factory.create();

        // Then
        assertThat(actual, notNullValue());
    }
}
