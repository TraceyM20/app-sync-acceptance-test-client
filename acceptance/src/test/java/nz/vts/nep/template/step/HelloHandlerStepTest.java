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

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;
import static org.mockito.Mockito.mock;
import static shiver.me.timbers.data.random.RandomStrings.someString;

import org.junit.jupiter.api.Test;

import nz.vts.nep.core.shared.component.api.domain.ApiClientException;
import nz.vts.nep.template.factory.IntroductionFactory;
import nz.vts.nep.template.hello.api.GreetingApi;
import nz.vts.nep.template.hello.model.Greeting;
import nz.vts.nep.template.hello.model.Introduction;
import nz.vts.nep.template.holder.ApiClientExceptionHolder;
import nz.vts.nep.template.holder.GreetingHolder;
import nz.vts.nep.template.holder.IntroductionHolder;

class HelloHandlerStepTest {

    private final GreetingApi greetingApi = mock(GreetingApi.class);
    private final IntroductionFactory introductionFactory = mock(IntroductionFactory.class);
    private final IntroductionHolder introductionHolder = mock(IntroductionHolder.class);
    private final GreetingHolder greetingHolder = mock(GreetingHolder.class);
    private final ApiClientExceptionHolder apiClientExceptionHolder = mock(ApiClientExceptionHolder.class);

    private final HelloHandlerStep helloHandlerStep =
            new HelloHandlerStep(greetingApi, introductionFactory, introductionHolder, greetingHolder, apiClientExceptionHolder);

    @Test
    void Can_introduce_person_with_name() {
        // Given
        final Introduction introduction = mock(Introduction.class);
        given(introductionFactory.introduceJane()).willReturn(introduction);

        // When
        helloHandlerStep.anIntroductionOfAPersonWithAName();

        // Then
        then(introductionHolder).should().set(introduction);
    }

    @Test
    void Can_seek_greeting() {
        // Given
        final Introduction introduction = mock(Introduction.class);
        final Greeting greeting = mock(Greeting.class);
        given(introductionHolder.get()).willReturn(introduction);
        given(greetingApi.sayHello(introduction)).willReturn(greeting);

        // When
        helloHandlerStep.aGreetingIsSought();

        // Then
        then(greetingHolder).should().set(greeting);
    }

    @Test
    void Can_fail_to_seek_greeting() {
        // Given
        final Introduction introduction = mock(Introduction.class);
        ApiClientException apiClientException = mock(ApiClientException.class);
        given(introductionHolder.get()).willReturn(introduction);
        given(greetingApi.sayHello(introduction)).willThrow(apiClientException);

        // When
        helloHandlerStep.aGreetingIsSought();

        // Then
        then(apiClientExceptionHolder).should().set(apiClientException);
    }

    @Test
    void Can_received_greeting_for_named_person() {
        // Given
        final Greeting greeting = mock(Greeting.class);
        given(greetingHolder.get()).willReturn(greeting);
        given(greeting.getOutput()).willReturn("Hello Jane" + someString());

        // When
        helloHandlerStep.theGreetingIsToTheNamedPerson();
    }

    @Test
    void Can_fail_to_received_greeting_for_named_person() {
        // Given
        final Greeting greeting = mock(Greeting.class);
        given(greetingHolder.get()).willReturn(greeting);
        given(greeting.getOutput()).willReturn(someString());

        // When
        assertThrows(AssertionError.class, () -> helloHandlerStep.theGreetingIsToTheNamedPerson());
    }

    @Test
    void Can_make_call_to_a_restricted_API_endpoint() {
        // Given
        final Introduction introduction = mock(Introduction.class);
        given(introductionHolder.get()).willReturn(introduction);

        // When
        helloHandlerStep.aCallIsMadeToARestrictedAPIEndpoint();

        // Then
        then(greetingApi).should().sayHello(introduction);
    }
}
