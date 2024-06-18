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

import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;
import static org.mockito.Mockito.mock;

import org.junit.jupiter.api.Test;

import nz.vts.nep.core.shared.component.api.domain.ApiClientException;
import nz.vts.nep.template.hello.api.HealthApi;
import nz.vts.nep.template.hello.model.Health;
import nz.vts.nep.template.holder.ApiClientExceptionHolder;
import nz.vts.nep.template.holder.HealthHolder;

class HealthCheckStepTest {

    private final HealthApi healthApi = mock(HealthApi.class);
    private final HealthHolder healthHolder = mock(HealthHolder.class);
    private final ApiClientExceptionHolder apiClientExceptionHolder = mock(ApiClientExceptionHolder.class);

    private final HealthCheckStep healthCheckStep = new HealthCheckStep(healthApi, healthHolder, apiClientExceptionHolder);

    @Test
    void Can_make_health_check_call() {
        // Given
        final Health health = mock(Health.class);
        given(healthApi.getHealth()).willReturn(health);

        // When
        healthCheckStep.aHealthCheckCallIsMade();

        // Then
        then(healthApi).should().getHealth();
        then(healthHolder).should().set(health);
    }

    @Test
    void Can_fail_to_make_a_health_check_call() {
        // Given
        final ApiClientException apiException = mock(ApiClientException.class);
        given(healthApi.getHealth()).willThrow(apiException);

        // When
        healthCheckStep.aHealthCheckCallIsMade();

        // Then
        then(healthApi).should().getHealth();
        then(apiClientExceptionHolder).should().set(apiException);
    }

    @Test
    void Can_validate_response_indicates_good_health() {
        // Given
        given(apiClientExceptionHolder.get()).willReturn(null);
        given(healthHolder.get()).willReturn(mock(Health.class));

        // When
        healthCheckStep.theResponseIndicatesGoodHealth();
    }

    @Test
    void Can_make_a_secure_health_check() {
        // Given
        final Health health = mock(Health.class);
        given(healthApi.getSecureHealth()).willReturn(health);

        // When
        healthCheckStep.aSecureHealthCheckCallIsMade();

        // Then
        then(healthApi).should().getSecureHealth();
        then(healthHolder).should().set(health);
    }

    @Test
    void Can_fail_to_make_a_secure_health_check() {
        // Given
        final ApiClientException apiException = mock(ApiClientException.class);
        given(healthApi.getSecureHealth()).willThrow(apiException);

        // When
        healthCheckStep.aSecureHealthCheckCallIsMade();

        // Then
        then(healthApi).should().getSecureHealth();
        then(apiClientExceptionHolder).should().set(apiException);
    }
}
