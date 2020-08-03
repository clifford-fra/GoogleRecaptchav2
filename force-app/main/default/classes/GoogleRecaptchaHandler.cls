public with sharing class GoogleRecaptchaHandler {

    @AuraEnabled
    public static String fetchBaseURL() {
        string orgURL = URL.getSalesforceBaseUrl().toString();
        return orgURL;
    }
        
    @AuraEnabled
    public static Boolean isVerified(String recaptchaResponse, String recaptchaSecretKey){
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
                return true;      
            } else {
                return false;
            }
        }
        
        return false;
    }
}