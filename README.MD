# Agillic SDK for iOS

This is a minimalistics SDK to support the Agillic Platform to:

 * Register devices used by a recipient,
 * Register the token required to send a Push Notification to a device using Apple PN on iOS or Firebase Cloud Messaging for Android.
 * Track recipient behavior, which can be used in Condition Editor for selection into Target Group

## Using the Agillic SDK

Create an instance of the Agillic SDK. No configuration except authentication is required for normal use. Authentication must be done before registration (or with registerWithAuthentication):

```swift
let agillicSDK = MobileSDK()
agillicSDK.setAuth(BasicAuth(user: key, password: secret))
AgillicTracker tracker = agillicSDK.register(clientAppId: clientAppId, clientAppVersion: clientVersion, 
                                             solutionId: solutionId, userID: recipientId , 
                                             pushNotificationToken: token, completion: completionHandler)        
```
For each unique Application view setup a constant UUID and view/screen name and use the returned AgillicTracker to send App View tracking to the Agillic Platform on this App view usage:

```
let event = AppViewEvent(self.uuid.uuidString, screenName: screenView)
tracker?.track(event)
```
The screenView is the value that can be matched in the Condition Editor and the suggested name convention to use some hierarchical app/sublevel-1/sublevel-2/...
