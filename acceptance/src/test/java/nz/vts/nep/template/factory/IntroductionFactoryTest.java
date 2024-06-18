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
import static org.hamcrest.Matchers.is;

import org.junit.jupiter.api.Test;

import nz.vts.nep.template.hello.model.Introduction;

class IntroductionFactoryTest {

    private final IntroductionFactory introductionFactory = new IntroductionFactory();

    @Test
    void Can_introduce_Jane() {
        // When
        final Introduction actual = introductionFactory.introduceJane();

        // Then
        assertThat(actual.getName(), is("Jane"));
    }
}
