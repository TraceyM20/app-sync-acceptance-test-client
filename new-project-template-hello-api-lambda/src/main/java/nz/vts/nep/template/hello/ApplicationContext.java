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

import static com.fasterxml.jackson.databind.DeserializationFeature.ACCEPT_EMPTY_STRING_AS_NULL_OBJECT;
import static com.fasterxml.jackson.databind.DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE;
import static com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES;
import static com.fasterxml.jackson.databind.SerializationFeature.FAIL_ON_EMPTY_BEANS;
import static com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS;

import javax.inject.Singleton;

import com.fasterxml.jackson.databind.ObjectMapper;

import nz.vts.nep.template.hello.spark.GreetingApiExceptionHandler;
import nz.vts.nep.template.hello.spark.GreetingApiResources;
import nz.vts.nep.template.hello.spark.GreetingApiService;
import nz.vts.nep.template.hello.spark.JsonTransformer;

import dagger.Component;
import dagger.Module;
import dagger.Provides;

@Module
public class ApplicationContext {

    private static String robot = System.getenv("robot");

    @Singleton
    @Component(modules = ApplicationContext.class)
    public interface ApplicationComponent {
        GreetingApiResources getGreetingApiResources();
    }

    public static GreetingApiResources getGreetingApiResources() {
        return DaggerApplicationContext_ApplicationComponent.create().getGreetingApiResources();
    }

    @Singleton
    @Provides
    public ObjectMapper objectMapper() {
        return (new ObjectMapper())
                .configure(WRITE_DATES_AS_TIMESTAMPS, false)
                .configure(FAIL_ON_EMPTY_BEANS, false)
                .configure(FAIL_ON_UNKNOWN_PROPERTIES, false)
                .configure(ADJUST_DATES_TO_CONTEXT_TIME_ZONE, false)
                .configure(ACCEPT_EMPTY_STRING_AS_NULL_OBJECT, true);
    }

    @Singleton
    @Provides
    public JsonTransformer jsonTransformer(
            ObjectMapper objectMapper
    ) {
        return new JsonTransformer(objectMapper);
    }

    @Singleton
    @Provides
    public GreetingApiResources greetingApiResources(
            GreetingApiService requestService,
            GreetingApiExceptionHandler templateHandler,
            JsonTransformer transformer
    ) {
        return new GreetingApiResources(requestService, templateHandler, transformer, transformer);
    }

    @Singleton
    @Provides
    public GreetingApiService greetingApiService() {
        return new IntroductionHandler(robot);
    }

    @Singleton
    @Provides
    public GreetingApiExceptionHandler greetingApiExceptionHandler() {
        return new IntroductionErrorHandler();
    }

}
