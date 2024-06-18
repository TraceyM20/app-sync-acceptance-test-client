/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template.factory;

import org.springframework.stereotype.Component;

import com.github.tomakehurst.wiremock.http.HttpHeader;
import com.github.tomakehurst.wiremock.http.HttpHeaders;

@Component
public class AuthorizationHttpHeadersFactory {
    public HttpHeaders create() {
        final HttpHeader xApiHeader = new HttpHeader("x-api-key", "([A-Za-z0-9\\s]*)");
        final HttpHeader authHeader = new HttpHeader("Authorization", "([A-Za-z0-9\\s]*)");

        return new HttpHeaders(xApiHeader, authHeader);
    }
}
