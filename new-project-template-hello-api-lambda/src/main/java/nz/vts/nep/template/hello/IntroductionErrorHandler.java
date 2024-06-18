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

import nz.vts.nep.template.hello.model.ErrorDetailBuilder;
import nz.vts.nep.template.hello.model.ErrorResponseBuilder;
import nz.vts.nep.template.hello.spark.GreetingApiExceptionHandler;

import spark.Request;
import spark.Response;

public class IntroductionErrorHandler implements GreetingApiExceptionHandler {

    @Override
    public Object sayHelloException(
            Request request,
            Response response,
            Exception exception
    ) {
        response.status(400);

        return new ErrorResponseBuilder()
                .withError(
                    new ErrorDetailBuilder()
                            .withCode("RUDE")
                            .withMessage(exception.getMessage())
                            .build()
                )
                .build();
    }
}
