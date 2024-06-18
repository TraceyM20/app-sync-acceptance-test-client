/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template;

import static nz.vts.nep.template.EndpointsConfig.SERVICE_URL;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.notNullValue;

import org.junit.jupiter.api.Test;

class EndpointsConfigTest {

    @Test
    void Can_get_key() {
        // When
        final String actual = SERVICE_URL.getKey();

        // Then
        assertThat(actual, notNullValue());
    }
}
