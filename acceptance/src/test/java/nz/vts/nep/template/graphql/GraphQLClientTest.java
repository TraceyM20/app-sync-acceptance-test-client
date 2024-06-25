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

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.cognitoidentityprovider.CognitoIdentityProviderClient;
import software.amazon.awssdk.services.cognitoidentityprovider.model.AdminInitiateAuthResponse;

class GraphQLClientTest {

    private GraphQLClient graphQLClient;

    @BeforeEach
    void setUp() {

        graphQLClient = new GraphQLClient();
    }

    @Test
    void testGetPost() {

        String otherJson = "query MyQuery {\n" +
                "  getPost(id: \"1\") {\n" +
                "    id,\n" +
                "    author,\n" +
                "  }\n" +
                "}";

        String response = graphQLClient.send(otherJson);

        System.out.println(response);
    }

    @Test
    void testAllPosts() {

        String otherJson = "query MyQuery {\n" +
                "  allPosts {\n" +
                "    author\n" +
                "    content\n" +
                "  }\n" +
                "}";

        String response = graphQLClient.send(otherJson);

        System.out.println(response);
    }

    @Test
    void testLogin() {

        ProfileCredentialsProvider creds = ProfileCredentialsProvider.builder().profileName("Sandbox").build();

        CognitoIdentityProviderClient cognitoClient = CognitoIdentityProviderClient.builder()
                .region(Region.AP_SOUTHEAST_2)
                .credentialsProvider(creds)
                .build();

        AdminInitiateAuthResponse response = graphQLClient.initiateAuth(
            cognitoClient,
            "3v7pagqmllf213ps5gjdsnrv22",
            "michael.tracey@vector.co.nz",
            "!ty_W0rd53cUr",
            "ap-southeast-2_VQ4us7FuL"
        );

        System.out.println(response);
    }
}
