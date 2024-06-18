/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template.holder;

import static org.hamcrest.CoreMatchers.instanceOf;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.notNullValue;

import org.junit.jupiter.api.Test;

import nz.vts.nep.verification.domain.GenericHolder;

class HealthHolderTest {
    @Test
    void Can_get_instance() {
        // When
        final HealthHolder actual = new HealthHolder();

        // Then
        assertThat(actual, notNullValue());
        assertThat(actual, instanceOf(GenericHolder.class));
    }
}
