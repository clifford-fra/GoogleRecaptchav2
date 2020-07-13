# Google Recaptcha v2 checkbox Flow Component for Salesforce

This component was developed by me, because I want to avoid any spam or brute force attacks on my flow, that is deployed with Lightning Out on an external page and on a community.

## Features

- Google Recaptcha v2 checkbox flow component
- A responsive layout, that adapts to the size of the recaptcha, especially the challenge window
- Server side verification of the recaptcha response
- Fully compatible to all browsers (tested with Firefox, Chrome, Internet Explorer, Chrome Mobile)

## Flow input and output variables

- `isHuman`: defaults to false, will be set to true, if the recaptcha verifies you as human
- `originPageURL`: insert the URL where the flow will run. e.g.: in the form of https://force-ability-5985-dev-ed--c.visualforce.com if you run it from the flow builder
- `enableServerSideVerification`: defaults to false, if set to true, the captcha response will be verified against your secret key in a callout to google
- `required`: defaults to true, make it required to pass the recaptcha
- `requiredMessage (optional)`: the error message displayed, if the user just clicks on next and has not verified he his human yet

## Installation instructions

At minimum for testing purposes, you just have to insert the correct `originPageURL` in the flow component. Then it will run with googles official test site and secret key. But in order to set up the component properly, you have to do the following:

### Part 1
Generate your own site and secret key here: https://www.google.com/recaptcha/

### Part 2
In the html file in the static resource `Google_Recaptcha`, update these lines and reupload the resource:
```javascript
var targetPageURL = "*";
var sitekey = '6Ldq2qwZAAAAAFtCcLEFEVkRk1V2EAe4FV1f4xnF';
```

`targetPageURL` will work with the wildcard `"*"`, but for security reasons, you should enter the URL, where the flow component runs. Remember: The component will only work if the domains in `targetPageURL` in the static resource, URL in your Browser and `originPageURL` in the flow components' input are the same (well except if you use the wildcard in the static resource, then only the last two need to be the same).

Setting the `targetPageURL` in the static resource to a specific URL means, that the flow component will only run on this domain. If you want to use the Recaptcha Component for example in your Org and in your community (with different domains), then leave the `targetPageURL` variable `"*"`.

Checkout this link to get more information: https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage

### Part 3
In the GoogleRecaptchaHandler apex class, insert your own secret key at the beginning:
```apex
private static String recaptchaSecretKey = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe';
```
