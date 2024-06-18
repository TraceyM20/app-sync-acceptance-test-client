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

import nz.vts.nep.template.hello.spark.GreetingApiRequestHandler;

public class HelloHandler extends GreetingApiRequestHandler {

    public HelloHandler() {
        super(ApplicationContext.getGreetingApiResources());
    }
}
