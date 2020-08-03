@IsTest
global with sharing class GoogleRecaptchaHandlerTest {

    @IsTest static void testIsVerified() {
        Test.setMock(HttpCalloutMock.class, new GoogleRecaptchaHandlerTest.RecaptchaHttpCalloutMock());

        System.assert(GoogleRecaptchaHandler.isVerified('8djkfhsdfjsd49234734', '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe'));
    }

    @IsTest static void testFetchBaseURL() {
        List<String> myURLs = GoogleRecaptchaHandler.fetchBaseURL();

        System.assertEquals(4, myURLs.size());
        System.assert(myURLs.contains(URL.getSalesforceBaseUrl().toExternalForm()));
    }

    global class RecaptchaHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
            global HTTPResponse respond(HTTPRequest request) {
                
                //First create a fake response
                HttpResponse response = new HttpResponse();
                
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"success":true, "challenge_ts": "2020-07-06T11:14:25Z", "hostname": "example.com"}');
                response.setStatusCode(200);
                
                return response;
            }
        }
}