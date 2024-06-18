/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template.authentication;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;

import nz.vts.nep.core.shared.cognito.api.CognitoApi;
import nz.vts.nep.core.shared.cognito.model.CreateTokenResponse;

public class CognitoAuthenticationToken {
    private static final String CLIENT_CREDENTIALS = "client_credentials";
    private static final ZoneId DEFAULT_ZONE_ID = ZoneId.systemDefault();
    private static final int TOKEN_VALIDITY_TIME_ADJUSTMENT_SECONDS = 10;

    private final CognitoApi cognitoApi;
    private final String clientId;
    private final String clientSecret;
    private OffsetDateTime authenticationValidUntil = OffsetDateTime.MIN;
    private CreateTokenResponse cognitoToken;

    public CognitoAuthenticationToken(
            final CognitoApi cognitoApi,
            final String clientId,
            final String clientSecret
    ) {
        this.cognitoApi = cognitoApi;
        this.clientId = clientId;
        this.clientSecret = clientSecret;
    }

    public String accessToken() {
        if (tokenRequiresRefresh()) {
            refreshAccessToken();
            calculateTimeToLive();
        }
        return this.cognitoToken.getAccessToken();
    }

    private boolean tokenRequiresRefresh() {
        return this.authenticationValidUntil.compareTo(OffsetDateTime.now()) < 0;
    }

    private void refreshAccessToken() {
        this.cognitoToken = this.cognitoApi
                .createToken(CLIENT_CREDENTIALS, this.clientId, this.clientSecret);
    }

    private void calculateTimeToLive() {
        this.authenticationValidUntil = OffsetDateTime
                .now(DEFAULT_ZONE_ID)
                .plus(this.cognitoToken.getExpiresIn(), ChronoUnit.SECONDS)
                .minus(TOKEN_VALIDITY_TIME_ADJUSTMENT_SECONDS, ChronoUnit.SECONDS);
    }

}
