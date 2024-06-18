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

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.notNullValue;

import org.junit.jupiter.api.Test;

class CognitoAuthenticationTokenLocalTest {

    private CognitoAuthenticationTokenLocal tokenLocal = new CognitoAuthenticationTokenLocal();

    @Test
    void Can_create_access_token() {

        // When
        final String token = tokenLocal.accessToken();

        // Then
        assertThat(token, notNullValue());
    }

}
