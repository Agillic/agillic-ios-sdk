//
//  AgillicAppViewEvent.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

import Foundation
import SnowplowTracker

public class AgillicAppView: AgillicTrackingEvent {
    var screenId: String
    var screenName: String
    var type: String?
    var previousScreenId: String?
    
    public init(screenName: String? = nil, type: String? = nil, previousScreenId: String? = nil) {
        self.screenId = SPUtilities.getUUIDString() ?? ""
        self.type = type
        self.previousScreenId = previousScreenId
        if let screenName = screenName {
            self.screenName = screenName
        } else {
            self.screenName = self.screenId
        }
    }
    
    private func buildSPEvent() -> SPScreenView? {
        let event = SPScreenView.build({ (builder : SPScreenViewBuilder?) -> Void in
            if let builder = builder {
                builder.setName(self.screenName)
                builder.setScreenId(self.screenId)
                builder.setType(self.type)
                builder.setPreviousScreenId(self.previousScreenId)
            }
        })
        return event
    }

    public override func track(_ tracker: SPTracker) {
        Agillic.shared.logger.log("[Agillic] App View Tracking: \(self.screenName)", level: .debug)
        tracker.track(buildSPEvent())
    }

}
