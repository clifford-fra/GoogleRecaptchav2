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
                
                // Store in platform cache
                Cache.Org.put(getCacheKey(flowInterviewGuid), DateTime.now());

                return true;      
            } else {
                return false;
            }
        }
        
        return false;
    }
    
    // Validate the Google reCAPTCHA has been submitted
    @InvocableMethod (label='Validate reCAPTCHA' description='Use the Flow Interview ID to validate the reCAPTCHA has been submitted by user')
    public static List<Boolean> validateRecaptcha(List<String> flowIntervewGuids) {  
        
        List<Boolean> validated = new List<Boolean>();

        for (String flowInterviewGuid :flowIntervewGuids) {

            // If we have a valid validation record
            if (Cache.Org.contains(getCacheKey(flowInterviewGuid))) {

                validated.add(true);

                // Remove the cache
                Cache.Org.remove(getCacheKey(flowInterviewGuid));
            }
            else {

                validated.add(false); 
            }
        }

        return validated;
    }

    public static String getCacheKey(String flowInterviewGuid) {
        return 'local.GoogleRecaptchaVerification.' + flowInterviewGuid.split('-')[0];
    }
}