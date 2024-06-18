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
import static org.hamcrest.MatcherAssert.assertThat;

import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

import nz.vts.nep.core.shared.component.api.domain.ApiClientException;
import nz.vts.nep.template.hello.api.HealthApi;
import nz.vts.nep.template.hello.model.Health;
import nz.vts.nep.template.holder.ApiClientExceptionHolder;
import nz.vts.nep.template.holder.HealthHolder;

public class HealthCheckStep {

    private final HealthApi healthApi;
    private final HealthHolder healthHolder;
    private final ApiClientExceptionHolder apiClientExceptionHolder;

    public HealthCheckStep(
            HealthApi healthApi,
            HealthHolder healthHolder,
            ApiClientExceptionHolder apiClientExceptionHolder
    ) {
        this.healthApi = healthApi;
        this.healthHolder = healthHolder;
        this.apiClientExceptionHolder = apiClientExceptionHolder;
    }

    @When("a health check call is made")
    public void aHealthCheckCallIsMade() {
        try {
            Health health = healthApi.getHealth();
            healthHolder.set(health);
        } catch (ApiClientException apiClientException) {
            apiClientExceptionHolder.set(apiClientException);
        }
    }

    @When("a secure health check call is made")
    public void aSecureHealthCheckCallIsMade() {
        try {
            Health health = healthApi.getSecureHealth();
            healthHolder.set(health);
        } catch (ApiClientException apiClientException) {
            apiClientExceptionHolder.set(apiClientException);
        }
    }

    @Then("the response indicates good health")
    public void theResponseIndicatesGoodHealth() {
        assertThat(apiClientExceptionHolder.get(), nullValue());
        assertThat(healthHolder.get(), notNullValue());
    }
}
