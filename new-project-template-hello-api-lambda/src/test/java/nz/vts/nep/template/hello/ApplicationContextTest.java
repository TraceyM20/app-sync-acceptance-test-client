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

import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.mockito.Mockito.mock;

import org.junit.jupiter.api.Test;

import com.fasterxml.jackson.databind.ObjectMapper;

import nz.vts.nep.template.hello.spark.GreetingApiExceptionHandler;
import nz.vts.nep.template.hello.spark.GreetingApiResources;
import nz.vts.nep.template.hello.spark.GreetingApiService;
import nz.vts.nep.template.hello.spark.JsonTransformer;

class ApplicationContextTest {

    final ApplicationContext context = new ApplicationContext();

    @Test
    void Can_get_greeting_api_resources() {
        // When
        final GreetingApiResources actual = context.getGreetingApiResources();

        // Then
        assertThat(actual, notNullValue());
    }

    @Test
    void Can_instantiate_object_mapper() {
        // When
        final ObjectMapper actual = context.objectMapper();

        // Then
        assertThat(actual, notNullValue());
    }

    @Test
    void Can_instantiate_json_transformer() {
        // Given
        final ObjectMapper objectMapper = mock(ObjectMapper.class);

        // When
        final JsonTransformer actual = context.jsonTransformer(objectMapper);

        // Then
        assertThat(actual, notNullValue());
    }

    @Test
    void Can_create_greeting_api_resources() {
        // Given
        final GreetingApiService requestService = mock(GreetingApiService.class);
        final GreetingApiExceptionHandler templateHandler = mock(GreetingApiExceptionHandler.class);
        final JsonTransformer transformer = mock(JsonTransformer.class);

        // When
        final GreetingApiResources actual =
                context.greetingApiResources(requestService, templateHandler, transformer);

        // Then
        assertThat(actual, notNullValue());
    }

    @Test
    void Can_instantiate_greeting_api_service() {
        // When
        final GreetingApiService actual = context.greetingApiService();

        // Then
        assertThat(actual, notNullValue());
    }

    @Test
    void Can_instantiate_greeting_api_exception_handler() {
        // When
        final GreetingApiExceptionHandler actual = context.greetingApiExceptionHandler();

        // Then
        assertThat(actual, notNullValue());
    }
}
