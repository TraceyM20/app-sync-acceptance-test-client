/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template.holder;

import org.springframework.stereotype.Component;

import io.cucumber.spring.ScenarioScope;

import nz.vts.nep.template.hello.model.Introduction;
import nz.vts.nep.verification.domain.GenericHolder;

@Component
@ScenarioScope
public class IntroductionHolder extends GenericHolder<Introduction> {
}
