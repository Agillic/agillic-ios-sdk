//
//  AgillicTracker.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

import Foundation
import SnowplowTracker

public class AgillicTracker {
    var tracker: SPTracker
    var enabled = true

    @objc public init(_ tracker: SPTracker) {
        self.tracker = tracker
    }
    
    public func track(_ event : AgillicTrackingEvent) {
        if self.enabled {
            event.track(self.tracker)
        }
    }
    
    public func getSPTracker() -> SPTracker {
        return self.tracker
    }

    public func pauseTracking() {
        self.enabled = false
    }

    public func resumeTracking() {
        self.enabled = false
    }
    
    public func isTracking() -> Bool {
        return self.enabled
    }
}
