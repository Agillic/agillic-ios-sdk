//
//  ScreenViewEvent.swift
//  SnowplowSwiftDemo
//
//  Created by Dennis Schafroth on 27/04/2020.
//  Copyright © 2020 Agillic. All rights reserved.
//

import Foundation
import SnowplowTracker

public class PushNotification : AgillicEvent {
    var screenId: String
    var screenName: String
    var type: String?
    var previousScreenId: String?
    
    public init(_ screenId: String, screenName: String? = nil, type: String? = nil, previousScreenId: String? = nil) {
        self.screenId = screenId
        self.screenName = screenName != nil ? screenName! : screenId
        self.type = type
        self.previousScreenId = previousScreenId
    }
    
    func getSnowplowEvent() -> SPPushNotification? {
        let event = SPPushNotification.build({(builder : SPPushNotificationBuilder?) -> Void in
            builder!.setTrigger("PUSH") // can be "PUSH", "LOCATION", "CALENDAR", or "TIME_INTERVAL"
            builder!.setAction("action")
            builder!.setDeliveryDate("date")
            builder!.setCategoryIdentifier("category")
            builder!.setThreadIdentifier("thread")
            // builder!.setNotification(content)
        })
        return event;
    }

    public func track(_ tracker: AgillicTracker) {
        track(tracker.tracker)
    }

    public override func track(_ tracker: SPTracker) {
        tracker.trackPushNotificationEvent(getSnowplowEvent())
    }

}
