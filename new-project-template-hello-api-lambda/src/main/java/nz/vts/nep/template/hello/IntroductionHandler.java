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

import nz.vts.nep.template.hello.model.Greeting;
import nz.vts.nep.template.hello.model.GreetingBuilder;
import nz.vts.nep.template.hello.model.Introduction;
import nz.vts.nep.template.hello.spark.GreetingApiService;

public class IntroductionHandler implements GreetingApiService {

    private String robot;

    public IntroductionHandler(
            String robot
    ) {
        this.robot = robot;
    }

    @Override
    public Greeting sayHello(
            Introduction introduction
    ) {
        final String name = introduction.getName();
        if (name == null) {
            throw new RuntimeException("Sorry, didn't quite catch that!");
        }
        final String output = String.format("Hello %s from %s in the lambda function", name, robot);
        return new GreetingBuilder().withOutput(output).build();
    }
}
