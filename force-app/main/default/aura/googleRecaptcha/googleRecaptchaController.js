({
    doInit: function(cmp, evt, helper) {

        // Reset the isHuman onRendering
        if (cmp.get("v.requiredOnce") === false) {
            cmp.set("v.isHuman", false);
        }
                
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
            var hasDomain = false;
            var listAllowedURLs = cmp.get("v.allowedURLs");

            if (listAllowedURLs === undefined || listAllowedURLs.length == 0) {
                return;
            }

            for (let i = 0; i < listAllowedURLs.length; i++) {
                if (listAllowedURLs[i] == event.origin) {
                    hasDomain = true;
                }
            }

            if (!hasDomain) {
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

                            // Let the animation wait a bit to fade out if required once
                            if (cmp.get("v.requiredOnce") === true) {
                                window.setTimeout(
                                    $A.getCallback(function() {
                                        cmp.set("v.isHuman", true);
                                    }), 500
                                );
                            } else {
                                // else do it directly
                                cmp.set("v.isHuman", true);
                            }
                           
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