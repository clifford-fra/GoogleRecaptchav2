({
    doInit: function(cmp, evt, helper) {

        // Reset the isHuman onRendering
        cmp.set("v.isHuman", false);
                
        // Parsing the originPageURLs
        var allowedURLs = [];

        if (cmp.get("v.originPageURL") != null) {
            var originPageURL = cmp.get("v.originPageURL");
            allowedURLs = originPageURL
                .split(",")
                .map(function(item) {
                    return item.trim();
                });
        }

        // Fetching your Salesforce ORG URLs
        helper.sendRequest(cmp, 'c.fetchBaseURL', {})
            .then($A.getCallback(function(records) {                
                cmp.set("v.allowedURLs", allowedURLs.concat(records));
            }))
            .catch(function(errors) {
                console.error('ERROR: ' + errors);
            });

        // Validating if the recaptcha has been passed successfully 
        cmp.set('v.validate', function() {

            let errorMessage = "Please complete the captcha";

            if (cmp.get("v.requiredMessage")) {
                errorMessage = cmp.get("v.requiredMessage");
            }

            if (cmp.get("v.required") && !cmp.get("v.isHuman")) {
                return { isValid: false, errorMessage: errorMessage};
            }          

            return { isValid: true };
        })

        // Listen to the events send from the iframe
        window.addEventListener("message", function(event) {

            // Security Check
            allowedURLs = JSON.stringify(cmp.get("v.allowedURLs"));

            if (allowedURLs === undefined || allowedURLs.length == 0 || allowedURLs.indexOf(event.origin) == -1) {
                return;
            }

            // Splitting up the event array
            var eventName = event.data[0];
            var data = event.data[1];

            // For debug reasons
            //console.log(eventName + ', ' + data + ', ' + event.origin);
            
            if (eventName==="setHeight") {
                cmp.find("captchaFrame").getElement().height = data;
            }
            if (eventName==="setWidth") {
                cmp.find("captchaFrame").getElement().width = data;
            }
            if (eventName==="Lock") {
                cmp.set("v.isHuman", false);
            }
            if (eventName==="Unlock") {
                if (cmp.get("v.enableServerSideVerification")) {
                    cmp.set("v.recaptchaResponse", data);
                    
                    // Create the server side apex verification
                    var params = {"recaptchaResponse" : cmp.get("v.recaptchaResponse"), "recaptchaSecretKey" : cmp.get("v.secretKey")};
                    helper.sendRequest(cmp, 'c.isVerified', params)
                    .then($A.getCallback(function(records) {
                        // If verified positive                    
                        if (records === true) {
                            cmp.set("v.isHuman", true);
                        }
                    }))
                    .catch(function(errors) {
                        console.error('ERROR: ' + errors);
                    });

                } else {
                    cmp.set("v.isHuman", true);
                }       
            }

        }, false);
    },

})