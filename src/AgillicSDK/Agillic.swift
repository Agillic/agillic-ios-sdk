//
//  AgillicSDK.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

import Foundation
import SnowplowTracker

typealias AgillicSDKResponse = (Result<String, NSError>) -> Void

public class Agillic : NSObject, SPRequestCallback {
    
    private let registrationEndpoint = "https://api-eu1.agillic.net/apps"
    private var snowplowEndpoint = "snowplowtrack-eu1.agillic.net"
    private var auth: Auth? = nil
    private(set) public var tracker: AgillicTracker? = nil
    private var clientAppId: String? = nil
    private var clientAppVersion: String? = nil
    private var solutionId : String? = nil
    private var pushNotificationToken: String?
    private var recipientId: String?
    private var count = 0
    private var requestCallback : AgillicRequestCallback? = nil
    private let notificationService = AgillicNotificationService()
    public let logger = AgillicLogger()
    
    // MARK: - Initializer & Usage methods
    
    /**
    Returns a global instance of AgillicSDK, it needs to be configured in other to be used.
     */
    public static var shared: Agillic = Agillic()
    
    private override init() {
        super.init()
    }
    
    /**
     Configure the AgillicSDK Instance with values from your Agillic solutions.

     - Parameter apiKey: Your personal Agillic API Key
     - Parameter apiSecret: Your personal Agillic API Key
     - Parameter solutionId: Your personal Agillic Solution ID
    
     All values can be obtained in your Agillic Solution, see Agillic documention how to obtain these values.
     */
    public func configure(apiKey: String, apiSecret: String, solutionId: String) {
        self.auth = BasicAuth(user: apiKey, password: apiSecret)
        self.clientAppId = SPUtilities.getAppId()
        self.clientAppVersion = SPUtilities.getAppVersion()
        self.solutionId = solutionId
    }
    
    /**
     Register this app installation into the Agillic solutiion.
     Create a new entry in the AGILLIC_REGISTRAION OTM Table in Recipient doesn't already have a Regration.
     
     - precondition: AgillicMobileSDK.shared().configure(:) must be called prior to this.
     - precondition: Recipient needs to exist in the Agillic Solution in order to successfully register the installation

     - Parameter recipientId: This is mapped to the Recipient.Email in the Agillic Solution.
     - Parameter pushNotificationToken: No description
     - Parameter completionHandler: success/failure callback
    
     - Throws:
            Error code: 1001 - solutionID missing
            Error code: 1002 - recipientId missing
            Error code: 3001 - registration Failed after 3 attempts
     
     Anonymous registrations are not yet supported.
     */
    public func register(recipientId: String, pushNotificationToken: String? = nil, completionHandler: ((String? , Error?) -> Void)? = nil)
    {
        self.recipientId = recipientId
        self.pushNotificationToken = pushNotificationToken
    
        guard let solutionId = self.solutionId else {
            let errorMsg = "Configuration not set"
            let error = NSError(domain: "configuration error", code: 1001, userInfo: ["message" : errorMsg])
            self.logger.log(errorMsg, level: .error)
            completionHandler?(nil, error)
            return
        }

        guard let spTracker = getTracker(recipientId: recipientId, solutionId: solutionId) else {
            let errorMsg = "Failed to create a tracker with the provided recipient and solution ID."
            let error = NSError(domain: "configuration error", code: 1001, userInfo: ["message" : errorMsg])
            self.logger.log(errorMsg, level: .error)
            completionHandler?(nil, error)
            return
        }

        self.tracker = AgillicTracker(spTracker)
        self.createMobileRegistration(inRegisterMode: true, recipientId: recipientId, completionHandler)
    }

    /**
     Unregister this app installation into the Agillic solutiion.

     - precondition: AgillicMobileSDK.shared().configure(:) must be called prior to this.
     - precondition: Recipient needs to exist in the Agillic Solution to in order successfully unregister the installation

     - Parameter recipientId: This is mapped to the Recipient.Email in the Agillic Solution.
     - Parameter completionHandler: success/failure callback

     - Throws:
            Error code: 1001 - solutionID missing
            Error code: 1002 - recipientId missing
            Error code: 3001 - registration Failed after 3 attempts
     */
    public func unregister(recipientId: String, completionHandler: ((String? , Error?) -> Void)? = nil) {
        guard let solutionId = self.solutionId else {
            let errorMsg = "Configuration not set"
            let error = NSError(domain: "configuration error", code: 1001, userInfo: ["message" : errorMsg])
            self.logger.log(errorMsg, level: .error)
            completionHandler?(nil, error)
            return
        }

        self.createMobileRegistration(inRegisterMode: false, recipientId: recipientId, completionHandler)
    }
    
    
    // MARK: - Tracking
    
    public func track(_ event : AgillicTrackingEvent) {
        guard let tracker = self.tracker else {
            let errorMsg = "Configuration not set"
            self.logger.log(errorMsg, level: .error)
            return
        }
        tracker.track(event)
    }
    
    /// Handles push notification opened - user action for alert notifications, delivery into app
    /// This method will parse the data and track it
    public func handlePushNotificationOpened(userInfo: [AnyHashable: Any]) {
        guard let agillicPushId = self.getAgillicPushId(userInfo: userInfo) else {
            self.logger.log("Skipping non-Agillic notification", level: .debug)
            return
        }
        let pushEvent = AgillicAppView(screenName: "pushOpened://agillic_push_id=\(agillicPushId)")
        self.track(pushEvent)
    }

    /// Handles mutable notifications
    /// This method will look for the `image` key in the notification payload and try to download and attach the image to the notification content
    public func handleNotificationRequest(_ request: UNNotificationRequest, contentHandler: @escaping (UNNotificationContent) -> Void) {

        guard self.isAgillicNotification(userInfo: request.content.userInfo) else {
            self.logger.log("Skipping non-Agillic notification", level: .verbose)
            return
        }

        self.notificationService.process(request: request, contentHandler: contentHandler)
    }

    public func serviceExtensionTimeWillExpire() {
        self.notificationService.serviceExtensionTimeWillExpire()
    }

    /// Validates it push notification opened - is a Agillic Push Notifcation based on payload
    private func getAgillicPushId(userInfo: [AnyHashable: Any]) -> String? {
        guard let userInfo = userInfo as? [String: AnyObject],
            let agillic_push_id = userInfo["agillic_push_id"] as? String else {
            return nil
        }
        return agillic_push_id
    }
    
    /// Validates it push notification opened - is a Agillic Push Notifcation based on payload
    private func isAgillicNotification(userInfo: [AnyHashable: Any]) -> Bool {
        return self.getAgillicPushId(userInfo: userInfo) != nil
    }
    

    // MARK: - Internal functionality

    private func getTracker(recipientId: String, solutionId: String) -> SPTracker? {
        let emitter = SPEmitter.build({ (builder : SPEmitterBuilder?) -> Void in
            guard let builder = builder else { return nil }
            builder.setUrlEndpoint(self.snowplowEndpoint)
            builder.setHttpMethod(SPRequestOptions.post)
            builder.setCallback(self)
            builder.setProtocol(SPProtocol.https)
            builder.setEmitRange(500)
            builder.setEmitThreadPoolSize(20)
            builder.setByteLimitPost(52000)
        })
        guard let subject = SPSubject(platformContext: true, andGeoContext: true) else { return nil }
        subject.setUserId(recipientId)
        let newTracker = SPTracker.build({ (builder : SPTrackerBuilder?) -> Void in
            guard let builder = builder else { return nil }
            builder.setEmitter(emitter)
            builder.setAppId(solutionId)
            builder.setBase64Encoded(false)
            builder.setSessionContext(true)
            builder.setSubject(subject)
            builder.setLifecycleEvents(true)
            builder.setAutotrackScreenViews(true)
            builder.setScreenContext(true)
            builder.setApplicationContext(true)
            builder.setExceptionEvents(true)
            builder.setInstallEvent(true)
        })
        return newTracker
    }
    
    private func createMobileRegistration(inRegisterMode: Bool, recipientId: String, _ completion: ((String?, Error?) -> Void)?) {

        let registrationModeString = inRegisterMode ? "registration" : "unregistration"

        let fullRegistrationUrl = inRegisterMode ? String(format: "%@/register/%@", self.registrationEndpoint, recipientId) : String(format: "%@/unregister/%@", self.registrationEndpoint, recipientId)
        guard let endpointUrl = URL(string: fullRegistrationUrl) else {
            let errorMsg = "Failed to create \(registrationModeString) \(fullRegistrationUrl)"
            let error = NSError(domain: "\(registrationModeString)", code: -1, userInfo: ["message" : errorMsg])
            self.logger.log(errorMsg, level: .error)
            completion?(nil, error)
            return
        }
        
        guard let clientAppId = self.clientAppId, let clientAppVersion = self.clientAppVersion, let auth = self.auth else {
            let errorMsg = "configuration not set"
            let error = NSError(domain: "configuration error", code: -1, userInfo: ["message" : errorMsg])
            self.logger.log(errorMsg, level: .error)
            completion?(nil, error)
            return
        }
        
        guard let tracker = self.tracker else {
            let errorMsg = "tracker not configured"
            let error = NSError(domain: "tracker", code: -1, userInfo: ["message" : errorMsg])
            self.logger.log(errorMsg, level: .error)
            completion?(nil, error)
            return
        }

        // Make JSON to send to send to server
        var json : [String:String] =
        [
            "appInstallationId": tracker.getSPTracker().getSessionUserId(),
            "clientAppId": clientAppId,
            "clientAppVersion": clientAppVersion,
            "osName" : SPUtilities.getOSType(),
            "osVersion" : SPUtilities.getOSVersion(),
            "deviceModel": SPUtilities.getDeviceModel(),
            "modelDimX" :  getXDimension(SPUtilities.getResolution()),
            "modelDimY" :  getYDimension(SPUtilities.getResolution())
        ]
        if inRegisterMode {
            json["pushNotificationToken"] = self.pushNotificationToken ?? ""
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            // Convert to a string and print
            if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                self.logger.log("\(registrationModeString.capitalized) JSON: \(JSONString)", level: .debug)
            }
    
            var request = URLRequest(url: endpointUrl)
            let authorization = auth.getAuthInfo()
            request.httpMethod = "PUT"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(authorization, forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
                guard let self = self else {
                    let error = NSError(domain: "\(registrationModeString)", code: 3001, userInfo: ["message" : "Lost reference to the Agillic SDK"])
                    DispatchQueue.main.async {
                        completion?(nil, error)
                    }
                    return
                }
                if let error = error {
                    self.logger.log("Failed \(registrationModeString): \(error.localizedDescription)", level: .error)
                    self.count += 1
                    if self.count < 3 {
                        // Make 3 attempts
                        sleep(5000)
                        self.createMobileRegistration(inRegisterMode: inRegisterMode, recipientId: recipientId, completion)
                    } else {
                        // Failed after three attempts
                        let errorMsg =  "Failed after 3 attempt: " + error.localizedDescription
                        let error = NSError(domain: "\(registrationModeString)", code: 3001, userInfo: ["message" : errorMsg])
                        self.logger.log(errorMsg, level: .error)
                        self.count = 0
                        DispatchQueue.main.async {
                            completion?(nil, error)
                        }
                    }
                } else {
                    //It's safe to cast URLResponse to HTTPURLResponse as long as the URL uses either a HTTP or HTTPS scheme.
                    let response = response as! HTTPURLResponse
                    if response.statusCode < 400 {
                        let message = "\(registrationModeString.capitalized) success response code: \(response.statusCode)"
                        self.logger.log(message, level: .debug)
                        DispatchQueue.main.async {
                            completion?(message, nil)
                        }
                    }
                    else {
                        let errorMsg = "\(registrationModeString.capitalized) failed with error code: \(response.statusCode)"
                        let error = NSError(domain: "\(registrationModeString)", code: -1, userInfo: ["message" : errorMsg])
                        self.logger.log(errorMsg, level: .error)
                        DispatchQueue.main.async {
                            completion?(nil, error)
                        }
                    }
                }
            })
            task.resume()
            self.logger.log("\(registrationModeString.capitalized) sent", level: .debug)
        } catch{
            self.logger.log("\(registrationModeString.capitalized) exception", level: .debug)
        }
    }
    
    // MARK: - Logging
    
    public func setLogLevel(_ logLevel: AgillicLogLevel) -> Void {
        self.logger.logLevel = logLevel
        switch logLevel {
        case .verbose:
            self.tracker?.tracker.setLogLevel(.verbose)
        case .debug:
            self.tracker?.tracker.setLogLevel(.debug)
        case .warning,
            .error:
            self.tracker?.tracker.setLogLevel(.error)
        case .off:
            self.tracker?.tracker.setLogLevel(.off)
        }
    }
    
    
    // MARK: - Util
    
    private func getXDimension(_ resolution: String) -> String {
        let slices = resolution.split(separator:"x")
        return String(slices.first ?? "?")
    }

    private func getYDimension(_ resolution: String) -> String {
        let slices = resolution.split(separator:"x")
        return String(slices.last ?? "?")
    }

    // MARK: - SPRequestCallback
    
    public func onSuccess(withCount successCount: Int) {
        requestCallback?.onSuccess(withCount: successCount)
    }

    public func onFailure(withCount failureCount: Int, successCount: Int) {
        requestCallback?.onFailure(withCount: failureCount, successCount: successCount)
    }
}

// MARK: - Auth
@objc private protocol Auth {
    @objc func getAuthInfo() -> String
}

private class BasicAuth : NSObject, Auth {
    var authInfo: String
    @objc public init(user : String, password: String) {
        let authString = "Basic \(user):\(password)"
        guard let authData = authString.data(using: .utf8) else {
            self.authInfo = ""
            return
        }
        self.authInfo = authData.base64EncodedString()
    }
    
    public func getAuthInfo() -> String {
        return authInfo
    }
}

// MARK: - Logger
    
public class AgillicLogger {
     
    public var logLevel: AgillicLogLevel = .off

    public func log(_ msg: String, level: AgillicLogLevel) {
        
        if self.logLevel <= level {
            NSLog(msg)
        }
    }

}

public enum AgillicLogLevel: Int, Comparable {
    case verbose
    case debug
    case warning
    case error
    case off

    // Implement Comparable
    public static func < (a: AgillicLogLevel, b: AgillicLogLevel) -> Bool {
        return a.rawValue < b.rawValue
    }
}
