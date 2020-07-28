# Google Recaptcha v2 checkbox Flow Component for Salesforce

This component was developed by me, because I want to avoid any spam or brute force attacks on my flow, that is deployed with Lightning Out on an external page and on a community.

## Basic Concept
The flow component actually relies on three parts: An aura component, an HTML static resource and an Apex class. The aura component embeds the static resource as an iframe. The HTML file references the Google Recaptcha API and renders the Recaptcha. The iframe tells the aura component the current height and width of the content (e.g. recaptcha challenge) by using `Window.postMessage` and will also communicate the captcha response in the same way after the user completes the challenge. The aura component will take the token and call a method in the apex class. The apex class will verify the token against the secret key in a callout to Google. If the verification is successful, the aura component will switch it's variable `isHuman` to `true` and let the user go to the next screen.

## Features

- Google Recaptcha v2 checkbox flow component
- A responsive layout, that adapts to the size of the recaptcha, especially the challenge window
- Server side verification of the recaptcha response
- Fully compatible to all browsers (tested with Firefox, Chrome, Internet Explorer, Chrome Mobile)

## Flow input and output variables

- `isHuman`: defaults to false, will be set to true, if the recaptcha verifies you as human
- `originPageURL`: insert the URL where the flow will run. e.g.: in the form of https://force-ability-5985-dev-ed--c.visualforce.com if you run it from the flow builder
- `enableServerSideVerification`: defaults to true, if set to false, the captcha response will not be verified against your secret key in a callout to google. Avoid turning this off
- `required`: defaults to true, makes it required to pass the recaptcha
- `requiredMessage (optional)`: the error message displayed, if the user just clicks on next and has not verified he his human yet
- `secretKey`: The secret key for your domain
- `siteKey`: The site key for your domain

## Installation instructions

An unmanaged Package can be installed from here:\
https://login.salesforce.com/packaging/installPackage.apexp?p0=04t2p0000010Rkd

Or use the Deploy to Salesforce button:\
<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

For testing purposes, you have to insert at minimum the correct `originPageURL` in the flow component. Then it will run with googles official test sitekey and secretkey. But in order to set up the component properly, you have to do the following:

### Part 1
Generate your own site and secret key here: https://www.google.com/recaptcha/

### Part 2
After you place the flow component on a screen, insert your `sitekey` and `secretkey`. Also set `originPageURL` correctly to the domain, where your flow runs in e.g. in the form of https://example.com. There's no need to add the rest of the URL path. It just needs to have the protocol, domain (and maybe the port).

## FAQ
- Why not use a lightning web component?
  - A lightning web component does not receive messages from the embedded iframe. Thus, the captcha response and the height of the content cannot be processed. This might be related to the Content Security Policy (CSP) of Salesforce.
  
- Why not use a Visualforce Page instead of a static resource?
  - A visualforce page is not public by default. Using Recaptcha means, that you often want to protect a flow, that is available for the public.

- Can you support Google Recaptcha v3?
  - I have to check but I don't think so. Maybe implementing Google Recaptcha v2 invisible would be easy.

- The Recaptcha tells me, that it can only be used for testing purposes!
  - Create your own site and secret key and insert them as explained.

- Eventhough I successfully passed the recaptcha challenge, the flow will not let me go to the next screen.
  - Check the `originPageURL`variable and set it correctly. Otherwise the aura component will not receive the recaptcha response.

- Is this component secure?
  - Well, I hope so. As long as the input variables of an aura component are considered secure (are they?), then this component is secure. Always activate the server side verification. If you want to increase security, then set the `targetPageURL` properly in the static resource if possible. See also: https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage

## Further Information
It's possible to host the HTML file of the static resource somewhere else. This is recommended if you use Lightning Out, because X-Frame-Options will not allow you to embed the static resource directly in an external page. If you do so, then you have to change the `src` tag in the aura component. You also have to add the iFrame URL to the `CSP Trusted Sites` in Salesforce Setup. Consequently, the `originPageURL` variable would be the iframes' location.
