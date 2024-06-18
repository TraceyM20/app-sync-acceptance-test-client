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

import nz.vts.nep.template.hello.model.Introduction;
import nz.vts.nep.template.hello.model.IntroductionBuilder;

@Component
public class IntroductionFactory {
    public Introduction introduceJane() {
        return new IntroductionBuilder()
                .withName("Jane")
                .build();
    }
}
