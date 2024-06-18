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

import org.apache.hc.core5.http.HttpRequest;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

import nz.vts.nep.core.shared.component.api.authentication.AuthenticationMethod;
import nz.vts.nep.core.shared.component.api.authentication.BearerTokenAuthenticationMethod;
import nz.vts.nep.core.shared.component.api.authentication.RequestHeaderAuthenticationMethod;
import nz.vts.nep.template.holder.ApiGatewayKeyHolder;
import nz.vts.nep.template.holder.AuthenticationTokenHolder;

public class HolderAwareAuthenticationMethod implements AuthenticationMethod, ApplicationContextAware {
    public static final String X_API_KEY = "x-api-key";
    private ApplicationContext applicationContext;

    @Override
    public void applyTo(
            final HttpRequest httpRequest
    ) {
        final AuthenticationTokenHolder authenticationTokenHolder =
                this.applicationContext.getBean(AuthenticationTokenHolder.class);
        final ApiGatewayKeyHolder apiGatewayKeyHolder = this.applicationContext.getBean(ApiGatewayKeyHolder.class);
        new RequestHeaderAuthenticationMethod(X_API_KEY, apiGatewayKeyHolder.get()).applyTo(httpRequest);
        new BearerTokenAuthenticationMethod(authenticationTokenHolder.get()).applyTo(httpRequest);
    }

    @Override
    public void setApplicationContext(
            final ApplicationContext applicationContext
    ) throws BeansException {
        this.applicationContext = applicationContext;
    }
}
