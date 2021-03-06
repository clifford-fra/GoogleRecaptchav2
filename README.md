# Google Recaptcha v2 checkbox Flow Component for Salesforce

This component was developed by me, because I want to avoid any spam or brute force attacks on my flow, that is deployed with Lightning Out on an external page and on a community.

## Basic Concept
The flow component actually relies on three parts: An aura component, an HTML static resource and an Apex class. The aura component embeds the static resource as an iframe. The HTML file references the Google Recaptcha API and renders the Recaptcha. The iframe tells the aura component the current height and width of the content (e.g. recaptcha challenge) by using `Window.postMessage` and will also communicate the captcha response in the same way after the user completes the challenge. In order to allow receiving messages from the iframe by `Window.postMessage`, the aura component uses a server-side call to generate a few permitted basic Salesforce URLs for the static resource. Afterwards, the aura component will take the token and call a method in the apex class. The apex class will verify the token against the secret key in a callout to Google. If the verification is successful, the aura component will switch it's variable `isHuman` to `true` and let the user go to the next screen.

## Features

- Google Recaptcha v2 checkbox flow component
- A responsive layout, that adapts to the size of the recaptcha, especially the challenge window
- Server side verification of the recaptcha response
- Fully compatible to all browsers (tested with Firefox, Chrome, Internet Explorer 9, Chrome Mobile)
- Run your flow on communities, lightning pages and almost anywhere

## Flow input and output variables

- `Is Human?`: defaults to false, will be set to true, if the recaptcha verifies you human
- `Origin Page URL (optional)`: A comma seperated list of URLs, where your flow runs. e.g.: in the form of: https://example.com, https://myOrg.force.com. OriginPageURL refers to the URL of the static resource, which contains the Recaptcha as HTML. The URL varies depending on where your flow is deployed. A default set of URLs is generated by the component: https://myOrgURL.my.salesforce.com, https://myOrgURL.lightning.force.com, https://myOrgURL--c.visualforce.com, https://myCommunityURL.force.com. For special URLs or cases, use this variable to add more URLs, especially those, that you have entered in the Google Recaptcha Admin Console.
- `Server Side Verification?`: defaults to true, if set to false, the captcha response will not be verified against your secret key in a callout to google. Avoid turning this off
- `Required?`: defaults to true, makes it required to pass the recaptcha
- `Required Message (optional)`: the error message displayed, if the user just clicks on next and has not verified he his human yet
- `Required only once?`: If true, the Recaptcha will only appear once. Else it will always appear on the screen. Consider this option, if you want to use the previous button to return to the screen, where this component is deployed. Defaults to false.
- `Recaptcha Secret Key`: The secret key for your domain
- `Recaptcha Site Key`: The site key for your domain
- `Recaptcha Frame Title (optional)`: For accessibility usage. Some browsers like Firefox won't directly tab into the checkbox and will instead focus the recaptcha frame at first. If you provide some text here, screenreaders will read this text if they focus the iframe. Defaults to: I'm not a robot captcha.

## Installation instructions

### Part 1
Use the Deploy to Salesforce button to install the component:\
<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

### Part 2
Generate your own site and secret key here: https://www.google.com/recaptcha/. I have added the Testkeys from Google as default, so you can try it out of the box.

### Part 3
Assign the user, that wants to run the flow, the Permission Set `Google Recaptcha Flow Component`. For example a to a Community Site Guest user by clicking on Settings in Experience Builder, under General select the Guest User Profile, then View Users, Select the Guest User, Edit Permission Set Assignments and add the Permission Set.

### Part 4
After you place the flow component on a screen, insert your `sitekey` and `secretkey`.

### Part 5 (optional)
Your flow is deployed somewhere else? Then set `originPageURL` correctly to the domain, where your flow runs in e.g. in the form of https://example.com. There's no need to add the rest of the URL path. It just needs to have the protocol, domain (and maybe the port). Some URLs are generated by the component, but they may not cover all deployment ways. Check the component reference for more information.

## FAQ
- Why not use a lightning web component?
  - A lightning web component does not receive messages from the embedded iframe. Thus, the captcha response and the height of the content cannot be processed. This might be related to the Content Security Policy (CSP) of Salesforce.
  
- Why not use a Visualforce Page instead of a static resource?
  - A visualforce page is not public by default. Using Recaptcha means, that you often want to protect a flow, that is available for the public.

- Can you support Google Recaptcha v3?
  - I have to check but I don't think so. Maybe implementing Google Recaptcha v2 invisible would be easy.

- The Recaptcha tells me, that it can only be used for testing purposes!
  - Create your own site and secret key and insert them as explained.

- The Recaptcha challenge is displayed in a small window, that is not scrollable
  - Check the `originPageURL`variable and set it correctly. Otherwise the aura component will not receive the correct height and width of the recaptcha challenge.

- Eventhough I successfully passed the recaptcha challenge, the flow will not let me go to the next screen.
  - Check the `originPageURL`variable and set it correctly. Otherwise the aura component will not receive the recaptcha response.
  - Check if the user, that runs the flow, has either the Permission Set `Google Recaptcha Flow Component` or directly assign access to the `GoogleRecaptchaHandler` Apex class.

- Is this component secure?
  - Well, no. To increase security, the Secret Key should be saved on the server e.g. in the Apex class. Always activate the server side verification. If you want to increase security, then set the `targetPageURL` properly in the static resource if possible. See also: https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage

## Further Information
It's possible to host the HTML file of the static resource somewhere else. This is recommended if you use Lightning Out, because X-Frame-Options will not allow you to embed the static resource directly in an external page. If you do so, then you have to change the `src` tag in the aura component. You also have to add the iFrame URL to the `CSP Trusted Sites` in Salesforce Setup. Consequently, the `originPageURL` variable would be the iframes' location.

## Contributions

I want to mention all sources that helped me to develop this component. Some of them were out in the wild for years, but I put all ideas together and added a bunch of new features like combining Aura component and a static resource, challenge detection and resizing, automatic URL creation and so on.

Jami Gibbs (Basic Concept)\
https://blog.jamigibbs.com/integrating-google-recaptcha-v2-into-a-salesforce-lightning-componentx/

Kevin Hill (Using a static resource)\
https://salesforce.stackexchange.com/questions/252419/google-recaptcha-v3-implementation-in-lightning-web-component

Craig Johnson (Server Side Verification)\
https://www.learncommunitycloud.com/s/article/Implementing-reCAPTCHA-in-Community-Cloud#RecaptchaV2Checkbox

Ramana Varasi (Basic Concept)\
http://varasi.com/salesforce/embedding-google-recaptcha-v2-in-salesforce-lightning-component-to-increase-security/

Miguel Duarte (Basic Concept)\
http://www.rightitservices.com/resource-hub/item/1319-google-recaptcha-v2-in-salesforce-custom-lightning-component

Xiaoan Lin (synchronous apex call)\
https://www.xgeek.net/salesforce/using-promise-for-apex-server-side-request-in-lightning-component/
