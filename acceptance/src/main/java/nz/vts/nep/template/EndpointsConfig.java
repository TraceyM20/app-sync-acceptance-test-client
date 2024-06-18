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

import nz.vts.nep.core.shared.component.domain.Configuration;

public enum EndpointsConfig implements Configuration {
    SERVICE_URL("service.base-url"),
    COGNITO_URL("cognito.url"),
    CLIENT_ID("authorised-client-id"),
    CLIENT_SECRET("authorised-client-secret"),
    GATEWAY_API_KEY("authorised-api-key"),
    DEVICE_DATA_STORE_API_KEY("device-data-store-api-key");

    private final String endpointConfig;

    EndpointsConfig(
            final String endpointConfig
    ) {
        this.endpointConfig = endpointConfig;
    }

    @Override
    public String getKey() {
        return this.endpointConfig;
    }
}
