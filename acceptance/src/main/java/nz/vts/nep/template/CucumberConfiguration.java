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

import static java.util.Collections.emptyList;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;

import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.Scenario;

import nz.vts.nep.verification.domain.GenericHolder;

@ContextConfiguration(classes = CucumberConfiguration.class)
public class CucumberConfiguration {
    private final Logger log = LoggerFactory.getLogger(getClass());

    @Autowired(required = false)
    private List<GenericHolder> holders = emptyList();

    @Before
    public void setup() {
        log.info("Scenario Start.");
    }

    @After
    public void tearDown(
            Scenario scenario
    ) {
        log.info("Scenario End.");
        if (scenario.isFailed()) {
            holders.forEach(holder -> log.error(holder.toString()));
        }
    }
}
