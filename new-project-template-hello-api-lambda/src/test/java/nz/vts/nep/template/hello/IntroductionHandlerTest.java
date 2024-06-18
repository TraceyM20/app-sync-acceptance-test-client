/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template.hello;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.mock;
import static shiver.me.timbers.data.random.RandomStrings.someAlphaString;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import nz.vts.nep.template.hello.model.Greeting;
import nz.vts.nep.template.hello.model.Introduction;

class IntroductionHandlerTest {

    private final String robot = someAlphaString(10);
    private IntroductionHandler handler;

    @BeforeEach
    void setup() {
        handler = new IntroductionHandler(robot);
    }

    @Test
    void Can_say_hello() {
        // Given
        final String name = someAlphaString(10);
        final Introduction introduction = mock(Introduction.class);

        given(introduction.getName()).willReturn(name);

        // When
        final Greeting actual = handler.sayHello(introduction);

        // Then
        assertThat(actual, notNullValue());
        assertThat(actual.getOutput(), containsString(name));
        assertThat(actual.getOutput(), containsString(robot));
    }

    @Test
    void Can_fail_to_say_hello_for_missing_name() {
        // Given
        final Introduction introduction = mock(Introduction.class);

        // When
        assertThrows(RuntimeException.class, () -> handler.sayHello(introduction));
    }

}
