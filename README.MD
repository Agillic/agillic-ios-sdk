# Agillic SDK for iOS

> __Please note__ The app SDK will be deprecated with the release of 23.0 in January 2023.  
> Use the [Register API](https://developers.agillic.com/apis/register-api#) instead

The Agillic SDK enables you to utilize the Agillic platform from within your iOS App.
The SDK currently includes the following functionality:

 * Register devices used by a recipient in your mobile application.
 * Register a recipient token required to send a Push Notification to a device using Apple PN on iOS or Firebase Cloud Messaging for Android. When registered, this token will allow sending push notifications to recipients via the Agillic Dashboard.
 * Track recipient App Views. Tracking can be paused and resumed when requested by the user. Tracked events can be used to define [Target Groups](https://support.agillic.com/hc/en-gb/articles/360007001991-All-You-Need-to-Know-About-Target-Groups) in the Agillic Dashboard which can be used to direct targeted marketing and other communication.

Other useful information:
* Read more about the Agillic Platform on the [Official Agillic website](https://agillic.com).
* And in our [Developer portal](https://developers.agillic.com).
* [Agillic Help Center](https://support.agillic.com/)
* The Agillic SDK for Android can be found here: [Agillic Android SDK](https://github.com/agillic/agillic-android-sdk/)

## Requirements

- Requires minimum iOS 11+

## Installation

See the subsections below for details about the different installation methods.
* [Swift Package Manager](README.md#swift-package-manager-(recommended))
* [Import Manually](README.md#import-manually)

### Swift Package Manager (recommended)

Add a package by selecting `File` → `Add Packages…` in Xcode’s menu bar.

Search for the Agillic iOS SDK using the repo's URL:
```console
https://github.com/agillic/agillic-ios-sdk.git
```

For detailed documentaion on setting up the Agillic SDK with Swift Package Manger see: 
[Swift Package Manager](docs/SwiftPackageManager.md)

### Import Manually
_NOTE: This is not the recommended method._ 

* Download this repository by selecting `Code` → `Download ZIP`.
* Open Downloads and locate ./src/AgillicSDK folder
* Drag and drop the AgillicSDK to your project
* Make sure to check `Copy items if needed` and Add to your App Target.
* The Agillic SDK are dependant on the Snowplow iOS Tracker SDK version 1.7.1 and FMDB (OUT OF SCOPE)

## Initializing the Agillic SDK

In order to use SDK you have to initialize and configure it first.

You can configure your Agillic instance in code:
* ``AGILLIC API KEY``
* ``AGILLIC API SECRET``
* ``AGILLIC SOLUTION ID``

See how to setup your Agillic Solution and obtain these values
in the [Agillic Solution Setup Guide](docs/AgillicSolutionSetup.md).

### Initialization

Start by importing the AgillicSDK Module into your `AppDelegate.swift` file

```swift
import AgillicSDK
```

Initialize and configure the Agillic SDK upon launch

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    Agillic.shared.configure(apiKey: "AGILLIC API KEY", apiSecret: "AGILLIC API SECRET", solutionId: "AGILLIC SOLUTION ID")
    return true
}
```

Your Agillic SDK instance is now ready for usage.

### Logging
Optionally you can enable logging for debug usage.
```swift
Agillic.shared.logger.logLevel = .verbose
```

## Usage

### Register App Installation

**Prerequisites**
* You need to make sure to do this AFTER `Agillic.shared.configure()`.
* You must do this upon every launch before doing any [App View Tracking](README.md#app-view-tracking). 
* Register has to be done in your Sign Up/Sign In flow but also on your splash screen if users are automatically logged in with an Access Token.
* ``RECIPIENT ID`` - Has to match the selected ID of the Reicipeint in Agillic. [Read how to change the RecipientID](https://support.agillic.com/hc/en-gb/articles/360014805631-How-to-Change-the-Recipient-ID)

###### Register App Installation
```swift
Agillic.shared.register(recipientId: "RECIPIENT ID")
```

### Register Push Token

**Prerequisites**
* Configure your app to be able to receive Push Notifications [Read this toturial](https://www.raywenderlich.com/11395893-push-notifications-tutorial-getting-started#)
* Read the [Agillic Push Notification Setup](docs/AgillicPushNotificationSetup.md) document to learn how to send Push Potifications to your iOS application directly from your Agillic Solution.

* Request permission for Remote Push Notifications in your App and obtain the Push Token from APNS

_NOTE: This requires you to have already obtained the Recipient ID and that you store this across app sessions - this is currently only supported for unknown recipients._

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
        } else {
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    return true
}
```

###### Register App Installation
Read `deviceToken` and add it to your Agillic Recipient.

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    let pushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    
    // Register with PushToken
    Agillic.shared.register(recipientId: "RECIPIENT ID", pushNotificationToken: pushToken)
}
```

### Unregister Push Token

If you wish to remove a push token from an Agillic Recipient, you can use the `unregister` function. This should be done when a user is logging out of your app.

```swift
Agillic.shared.unregister(recipientId: "Recipient ID")
```

## Reading Push Notification sent from your Agillic

### Track Push Opened 

The SDK can be used to track if a recipient has opened a push notification sent from Agillic. To do this, conform your `AppDelegate` class to `UNUserNotificationCenterDelegate` and implement the following function

```swift
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        Agillic.shared.handlePushNotificationOpened(userInfo: response.notification.request.content.userInfo)

        completionHandler()
    }
}
```

_NOTE: By default, your app wont show notifications if the app is in foreground. If you want to support this, add the following function_

```swift
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
```

## Handling deeplinking from Agillic

By default, when a recipient clicks on your app push message, the app opens.
If you want the App to deeplink to a specific screen / page / product in your app. You can use the `on_click` variable that is passed from the Agillic Solution.

**Example**


```swift
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // ex: on_click = "app://product-offers/21
        if let deeplink = response.notification.request.content.userInfo["on_click"] as? String {
        	//Handle your deeplinking here
     	}   
    }
}
```

## Rich push notifications
### Image attachments

For your iOS application to be able to show notifications with an image attached, you need to create a `Notification Service Extension` which will modify the content of a remote notification before it’s delivered to the recipient.

**To create the extension:**

1. Select `File/New/Target` in the Xcode menu bar.
2. Search for `notification` in the filter field.
3. Select `Notification Service Extension`
4. Give it a suitable name and make sure that the `Project` and `Embed in Application` field is set to your main app.

**Dependency configuration**

Add the Agillic SDK to your extension as shown in the image below

<a href="https://ibb.co/LhLncWJ"><img src="https://i.ibb.co/XkhSKg3/Screenshot-2022-01-26-at-14-36-08.png" alt="Screenshot-2022-01-26-at-14-36-08" border="0"></a>

**Configure your Notification Service Extension**

Finally, navigate to your extension, open `NotificationService.swift` and call the Agillic functions for processing notifications and handling timeouts.

```swift
import Foundation
import UserNotifications
import AgillicSDK

class NotificationService: UNNotificationServiceExtension {

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
	Agillic.shared.handleNotificationRequest(request, contentHandler: contentHandler)
    }

    override func serviceExtensionTimeWillExpire() {
	Agillic.shared.serviceExtensionTimeWillExpire()
    }

}
```

***Voilà!***

Your app is now able to show the attached image in an Agillic notification!


### Custom Actions
Not yet supported.

## App View Tracking

Track recipient behavior with App View Tracking.

App View Tracking is typically located in your `UIViewController` file, but can be used elsewhere if needed.

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let appView = AgillicAppView(screenName: "app://sublevel-1/sublevel-2")
    Agillic.shared.tracker.track(appView)
}
```

The ``screenName`` is the value that can be matched in the Condition Editor.
We suggest to use a hierarchical naming convention, prefixed with `app://` ex:
* ``app://sublevel-1/sublevel-2/...``

*Examples of usage:*
* ``app://landingpage``
* ``app://landingpage/sign-up/step-2``
* ``app://dashboard``
* ``app://product-offers``
* ``app://product-offers/21``
* ``app://menu/profile/edit``

## Questions and Issues

Please provide any feedback via a [GitHub Issue](https://github.com/agillic/agillic-ios-sdk/issues/new).

## Copyright and license

Agillic SDK for iOS is available under the Apache 2.0 license. See [LICENSE](LICENSE) file for more info.

```
   Copyright 2022 Agillic

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

