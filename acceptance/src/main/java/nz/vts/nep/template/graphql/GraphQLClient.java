/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template.graphql;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import software.amazon.awssdk.services.cognitoidentityprovider.CognitoIdentityProviderClient;
import software.amazon.awssdk.services.cognitoidentityprovider.model.AdminInitiateAuthRequest;
import software.amazon.awssdk.services.cognitoidentityprovider.model.AdminInitiateAuthResponse;
import software.amazon.awssdk.services.cognitoidentityprovider.model.AuthFlowType;
import software.amazon.awssdk.services.cognitoidentityprovider.model.CognitoIdentityProviderException;

@Controller
public class GraphQLClient {

    private static final String BASE_URL = "https://gwxjogrkrnfyhpl2uzowwyiwi4.appsync-api.ap-southeast-2.amazonaws.com";
    private static final String API_KEY = "da2-nnoihsxbxvaenhe5s2qjixsdzi";

    public GraphQLClient() {
    }

    private WebClient.RequestBodySpec configureRequest() {

        return WebClient
                .builder()
                .baseUrl(BASE_URL)
                .defaultHeader("x-api-key", API_KEY)
                .build()
                .method(HttpMethod.POST)
                .uri("/graphql");
    }

    public String send(
            String inputJson
    ) {

        Map<String, Object> requestBody = new HashMap<>();

        requestBody.put("query", inputJson);

        WebClient.RequestBodySpec requestBodySpec = configureRequest();

        WebClient.ResponseSpec response = requestBodySpec
                .body(BodyInserters.fromValue(requestBody))
                .accept(MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML)
                .acceptCharset(StandardCharsets.UTF_8)
                .retrieve();

        return response.bodyToMono(String.class).block();
    }

    public void loginCognito() {

        String clientId = "";
        String clientSecret = "";

        String callback = ""; // dont need this

    }
    public AdminInitiateAuthResponse initiateAuth(
            CognitoIdentityProviderClient identityProviderClient,
            String clientId,
            String userName,
            String password,
            String userPoolId
    ) {
        try {
            Map<String, String> authParameters = new HashMap<>();
            authParameters.put("USERNAME", userName);
            authParameters.put("PASSWORD", password);

            AdminInitiateAuthRequest authRequest = AdminInitiateAuthRequest.builder()
                    .clientId(clientId)
                    .userPoolId(userPoolId)
                    .authParameters(authParameters)
                    .authFlow(AuthFlowType.ADMIN_USER_PASSWORD_AUTH)
                    .build();

            AdminInitiateAuthResponse response = identityProviderClient.adminInitiateAuth(authRequest);
            System.out.println("Result Challenge is : " + response.challengeName());
            return response;

        } catch (CognitoIdentityProviderException e) {
            System.err.println(e.awsErrorDetails().errorMessage());
            System.exit(1);
        }

        return null;
    }

}
