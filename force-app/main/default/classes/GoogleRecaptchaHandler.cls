public with sharing class GoogleRecaptchaHandler {

    @AuraEnabled
    public static List<String> fetchBaseURL() {
        List<String> allowedURLs = new List<String>();

        allowedURLs.add(URL.getOrgDomainUrl().toExternalForm());
        allowedURLs.add(URL.getSalesforceBaseUrl().toExternalForm());
        allowedURLs.add(URL.getOrgDomainUrl().toExternalForm().replace('.my.salesforce.com', '.lightning.force.com'));
        allowedURLs.add(URL.getOrgDomainUrl().toExternalForm().replace('.my.salesforce.com', '--c.visualforce.com'));

        return allowedURLs;
    } 
        
    @AuraEnabled
    public static Boolean isVerified(String recaptchaResponse, String recaptchaSecretKey, String flowInterviewGuid){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        request.setMethod('POST');
        request.setBody('secret=' + recaptchaSecretKey + '&response=' + recaptchaResponse);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if (result.containsKey('success') && result.get('success') == true) {      
                
                // Log validation of the submitted 
                logValidation(flowInterviewGuid);

                return true;      
            } else {
                return false;
            }
        }
        
        return false;
    }
    
    public static void logValidation (String flowInterviewGuid) {

        // Insert a unique reference for the Flow Interview ID
        try {
            insert new Google_reCAPTCHA_Validation__c(
                Name = processFlowInterviewGuid(flowInterviewGuid)
            );
        }
        catch (Exception ex) {
            system.debug('### Already validated');
        }
    }

    // Validate the Google reCAPTCHA has been submitted
    @InvocableMethod (label='Validate reCAPTCHA' description='Use the Flow Interview ID to validate the reCAPTCHA has been submitted by user')
    public static List<Boolean> validateRecaptcha(List<String> flowIntervewGuids) {  
        
        List<Boolean> validated = new List<Boolean>();

        for (String flowInterviewGuid :flowIntervewGuids) {

            // Retrieve the verification record
            Google_reCAPTCHA_Validation__c captchaValidation = 
                Google_reCAPTCHA_Validation__c.getInstance(processFlowInterviewGuid(flowInterviewGuid));

            // If we have a valid validation record
            if (captchaValidation != null) {

                validated.add(true);

                // Once we've verified the reCAPTCHA, we can delete it.
                delete captchaValidation;
            }
            else {

                validated.add(false); 
            }
        }

        return validated;
    }

    // Limit flowInterviewGuid to 38 chars as that is max for custom setting name
    public static String processFlowInterviewGuid(String flowInterviewGuid) {
        return flowInterviewGuid.split('-')[0].left(38);
    }
}