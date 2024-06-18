/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template;

import static com.fasterxml.jackson.databind.DeserializationFeature.ACCEPT_EMPTY_STRING_AS_NULL_OBJECT;
import static com.fasterxml.jackson.databind.DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE;
import static com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES;
import static com.fasterxml.jackson.databind.SerializationFeature.FAIL_ON_EMPTY_BEANS;
import static com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS;

import java.net.URI;
import java.net.URISyntaxException;
import java.time.DateTimeException;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;

import org.apache.hc.client5.http.impl.DefaultHttpRequestRetryStrategy;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.HttpClientBuilder;
import org.apache.hc.core5.util.TimeValue;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import com.amazonaws.services.simplesystemsmanagement.AWSSimpleSystemsManagement;
import com.amazonaws.services.simplesystemsmanagement.AWSSimpleSystemsManagementClientBuilder;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import nz.vts.nep.core.shared.cognito.api.CognitoApi;
import nz.vts.nep.core.shared.component.ConfigurationStore;
import nz.vts.nep.core.shared.component.DateTimeUtilities;
import nz.vts.nep.core.shared.component.api.ApiClient;
import nz.vts.nep.core.shared.component.api.ApiSerializationUtilities;
import nz.vts.nep.core.shared.component.api.factory.DefaultMultiPartFormFactory;
import nz.vts.nep.core.shared.component.configuration.CombinedConfigurationStore;
import nz.vts.nep.core.shared.component.configuration.CombinedConfigurationStoreBooleanValueConverter;
import nz.vts.nep.core.shared.component.configuration.CombinedConfigurationStoreIntegerValueConverter;
import nz.vts.nep.core.shared.component.configuration.CombinedConfigurationStoreLocalDateValueConverter;
import nz.vts.nep.core.shared.component.configuration.CombinedConfigurationStoreOffsetDateTimeValueConverter;
import nz.vts.nep.core.shared.component.configuration.CombinedConfigurationStoreStringValueConverter;
import nz.vts.nep.core.shared.component.configuration.CombinedConfigurationStoreUriValueConverter;
import nz.vts.nep.core.shared.component.configuration.EnvironmentalConfigurationStore;
import nz.vts.nep.core.shared.component.domain.ProcessException;
import nz.vts.nep.core.shared.component.domain.TimeZoneConfiguration;
import nz.vts.nep.core.shared.component.lambda.AwsParameterStoreConfigurationProvider;
import nz.vts.nep.core.shared.component.process.DelayService;
import nz.vts.nep.core.shared.component.process.PagedItemRetrieverService;
import nz.vts.nep.core.shared.component.process.factory.CountDownLatchFactory;
import nz.vts.nep.template.authentication.CognitoAuthenticationToken;
import nz.vts.nep.template.authentication.CognitoAuthenticationTokenLocal;
import nz.vts.nep.template.authentication.HolderAwareAuthenticationMethod;
import nz.vts.nep.template.hello.api.GreetingApi;

@Configuration
public class ApplicationConfiguration {

    private static final String PROFILE_NON_LOCAL = "!local";

    private static final String PROFILE_LOCAL = "local";

    private static final String BASE_PATH = "/vts-nep-new-project-template/build-acceptance/";

    public static final String SERVICE_URL = "SERVICE_URL";

    @Bean
    @Profile(PROFILE_NON_LOCAL)
    public AWSSimpleSystemsManagement providesAwsSimpleSystemsManagement() {
        return AWSSimpleSystemsManagementClientBuilder.standard().build();
    }

    @Bean
    @Profile(PROFILE_NON_LOCAL)
    public PagedItemRetrieverService providesPagedItemRetrieverService() {
        final CountDownLatchFactory countDownLatchFactory = new CountDownLatchFactory();
        final DelayService delayService = new DelayService(countDownLatchFactory);
        return new PagedItemRetrieverService(delayService);
    }

    @Bean
    @Profile(PROFILE_NON_LOCAL)
    public ConfigurationStore providesConfigurationStore(
            final PagedItemRetrieverService pagedItemRetrieverService,
            final AWSSimpleSystemsManagement awsSimpleSystemsManagement
    ) {

        final CombinedConfigurationStore.Builder configurationStoreBuilder = CombinedConfigurationStore.builder();
        return configurationStoreBuilder
                .with(
                    new AwsParameterStoreConfigurationProvider(
                            pagedItemRetrieverService,
                            awsSimpleSystemsManagement,
                            BASE_PATH
                    )
                )
                .with(new CombinedConfigurationStoreStringValueConverter(), String.class)
                .with(new CombinedConfigurationStoreUriValueConverter(), URI.class)
                .with(new CombinedConfigurationStoreIntegerValueConverter(), Integer.class)
                .with(new CombinedConfigurationStoreBooleanValueConverter(), Boolean.class)
                .with(new CombinedConfigurationStoreOffsetDateTimeValueConverter(), OffsetDateTime.class)
                .with(new CombinedConfigurationStoreLocalDateValueConverter(), LocalDate.class)
                .build();
    }

    @Bean
    @Profile(PROFILE_LOCAL)
    public ConfigurationStore localConfigurationStore() {
        return new EnvironmentalConfigurationStore();
    }

    @Bean
    public ObjectMapper objectMapper() {
        return (new ObjectMapper())
                .registerModule(new JavaTimeModule())
                .configure(WRITE_DATES_AS_TIMESTAMPS, false)
                .configure(FAIL_ON_EMPTY_BEANS, false)
                .configure(FAIL_ON_UNKNOWN_PROPERTIES, false)
                .configure(ADJUST_DATES_TO_CONTEXT_TIME_ZONE, false)
                .configure(ACCEPT_EMPTY_STRING_AS_NULL_OBJECT, true);
    }

    @Bean
    public ApiClient apiClient(
            final ObjectMapper objectMapper
    ) {
        final CloseableHttpClient client = HttpClientBuilder.create()
                .setConnectionReuseStrategy((httpRequest, httpResponse, httpContext) -> false)
                .setRetryStrategy(new DefaultHttpRequestRetryStrategy(3, TimeValue.ofSeconds(2)))
                .build();
        return new ApiClient(
                client,
                new DefaultMultiPartFormFactory(),
                new ApiSerializationUtilities(objectMapper)
        );
    }

    @Bean
    public HolderAwareAuthenticationMethod holderAwareAuthenticationMethod() {
        return new HolderAwareAuthenticationMethod();
    }

    @Bean
    public GreetingApi greetingApi(
            final ApiClient apiClient,
            @Qualifier(SERVICE_URL) final URI serviceUrl,
            final HolderAwareAuthenticationMethod authenticationMethod
    ) {
        return new GreetingApi(apiClient, serviceUrl, authenticationMethod);
    }

    @Bean
    @Qualifier(SERVICE_URL)
    public URI serviceUrl(
            final ConfigurationStore configurationStore
    ) throws URISyntaxException {
        return new URI(configurationStore.getUnwrapped(EndpointsConfig.SERVICE_URL, String.class));
    }

    @Bean
    @Profile(PROFILE_NON_LOCAL)
    public CognitoAuthenticationToken cognitoAuthenticationToken(
            final ApiClient apiClient,
            final ConfigurationStore configurationStore
    ) {
        final URI serviceUrl = configurationStore.getUnwrapped(EndpointsConfig.COGNITO_URL, URI.class);
        final CognitoApi cognitoApi = new CognitoApi(apiClient, serviceUrl);
        final String clientId = configurationStore.getUnwrapped(EndpointsConfig.CLIENT_ID, String.class);
        final String clientSecret = configurationStore.getUnwrapped(EndpointsConfig.CLIENT_SECRET, String.class);
        return new CognitoAuthenticationToken(cognitoApi, clientId, clientSecret);
    }

    @Bean
    @Profile(PROFILE_LOCAL)
    public CognitoAuthenticationToken localCognitoAuthenticationToken() {
        return new CognitoAuthenticationTokenLocal();
    }

    @Bean
    public DateTimeUtilities dateTimeUtilities(
            final ConfigurationStore configurationStore
    ) {
        final ZoneId businessTimeZone =
                this.getTimeZone(configurationStore, TimeZoneConfiguration.ZoneConfiguration.BUSINESS_TIMEZONE);
        final ZoneId quantityTimeZone =
                this.getTimeZone(configurationStore, TimeZoneConfiguration.ZoneConfiguration.QUANTITY_TIMEZONE);
        final ZoneId systemTimeZone = this.getTimeZone(configurationStore, TimeZoneConfiguration.ZoneConfiguration.SYSTEM_TIMEZONE);
        final TimeZoneConfiguration timeZoneConfiguration =
                new TimeZoneConfiguration(businessTimeZone, quantityTimeZone, systemTimeZone);
        return new DateTimeUtilities(timeZoneConfiguration);
    }

    private ZoneId getTimeZone(
            final ConfigurationStore configurationStore,
            final TimeZoneConfiguration.ZoneConfiguration businessTimezone
    ) {
        try {
            return ZoneId.of(configurationStore.getUnwrapped(businessTimezone, String.class));
        } catch (final DateTimeException var4) {
            throw new ProcessException("Invalid time zone given by configuration", var4);
        }
    }
}
