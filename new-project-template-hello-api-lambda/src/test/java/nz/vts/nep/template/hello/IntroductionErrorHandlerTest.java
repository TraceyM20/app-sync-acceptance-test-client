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

import static org.hamcrest.CoreMatchers.instanceOf;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;
import static org.mockito.Mockito.mock;
import static shiver.me.timbers.data.random.RandomStrings.someString;

import org.junit.jupiter.api.Test;

import nz.vts.nep.template.hello.model.ErrorResponse;

import spark.Request;
import spark.Response;

class IntroductionErrorHandlerTest {

    private IntroductionErrorHandler handler = new IntroductionErrorHandler();

    @Test
    void Can_create_say_hello_exception() {
        // Given
        final Request request = mock(Request.class);
        final Response response = mock(Response.class);
        final Exception template = mock(Exception.class);
        final String message = someString();

        given(template.getMessage()).willReturn(message);

        // When
        final Object actual = handler.sayHelloException(request, response, template);

        // Then
        assertThat(actual, instanceOf(ErrorResponse.class));
        assertThat(((ErrorResponse) actual).getError().getCode(), is("RUDE"));
        assertThat(((ErrorResponse) actual).getError().getMessage(), is(message));
        then(response).should().status(400);
    }
}
