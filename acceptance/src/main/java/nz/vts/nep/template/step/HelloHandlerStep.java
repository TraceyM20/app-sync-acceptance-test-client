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

import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.CoreMatchers.startsWith;
import static org.hamcrest.MatcherAssert.assertThat;

import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

import nz.vts.nep.core.shared.component.api.domain.ApiClientException;
import nz.vts.nep.template.factory.IntroductionFactory;
import nz.vts.nep.template.hello.api.GreetingApi;
import nz.vts.nep.template.hello.model.Greeting;
import nz.vts.nep.template.hello.model.Introduction;
import nz.vts.nep.template.holder.ApiClientExceptionHolder;
import nz.vts.nep.template.holder.GreetingHolder;
import nz.vts.nep.template.holder.IntroductionHolder;

public class HelloHandlerStep {
    private final GreetingApi greetingApi;
    private final IntroductionFactory introductionFactory;
    private final IntroductionHolder introductionHolder;
    private final GreetingHolder greetingHolder;
    private final ApiClientExceptionHolder apiClientExceptionHolder;

    public HelloHandlerStep(
            GreetingApi greetingApi,
            IntroductionFactory introductionFactory,
            IntroductionHolder introductionHolder,
            GreetingHolder greetingHolder,
            ApiClientExceptionHolder apiClientExceptionHolder
    ) {
        this.greetingApi = greetingApi;
        this.introductionFactory = introductionFactory;
        this.introductionHolder = introductionHolder;
        this.greetingHolder = greetingHolder;
        this.apiClientExceptionHolder = apiClientExceptionHolder;
    }

    @Given("An introduction of a person with a name")
    public void anIntroductionOfAPersonWithAName() {
        final Introduction introduction = introductionFactory.introduceJane();
        introductionHolder.set(introduction);
    }

    @When("a greeting is sought")
    public void aGreetingIsSought() {
        final Introduction introduction = introductionHolder.get();
        try {
            Greeting greeting = greetingApi.sayHello(introduction);
            greetingHolder.set(greeting);
        } catch (ApiClientException apiClientException) {
            apiClientExceptionHolder.set(apiClientException);
        }
    }

    @When("a call is made to a restricted API endpoint")
    public void aCallIsMadeToARestrictedAPIEndpoint() {
        anIntroductionOfAPersonWithAName();
        aGreetingIsSought();
    }

    @Then("the greeting is to the named person")
    public void theGreetingIsToTheNamedPerson() {
        final Greeting greeting = greetingHolder.get();
        assertThat(greeting, notNullValue());
        final ApiClientException apiClientException = apiClientExceptionHolder.get();
        assertThat(apiClientException, nullValue());
        assertThat(greeting.getOutput(), notNullValue());
        assertThat(greeting.getOutput(), startsWith("Hello Jane"));
    }
}
