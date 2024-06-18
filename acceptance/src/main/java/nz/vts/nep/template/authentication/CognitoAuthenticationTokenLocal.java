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

import static shiver.me.timbers.data.random.RandomStrings.someAlphanumericString;

public class CognitoAuthenticationTokenLocal extends CognitoAuthenticationToken {

    public CognitoAuthenticationTokenLocal() {
        super(null, "", "");
    }

    @Override
    public String accessToken() {
        return someAlphanumericString(32);
    }
}
