//
//  AgillicTracker.swift
//  SnowplowSwiftDemo
//
//  Created by Dennis Schafroth on 27/04/2020.
//  Copyright © 2020 snowplowanalytics. All rights reserved.
//

import Foundation
import SnowplowTracker


public class AgillicTracker  {
    var tracker: SPTracker
    var enabled = true

    public init(_ tracker: SPTracker) {
        self.tracker = tracker
    }
    
    public func track(_ event : AgillicEvent) {
        if (enabled) {
            event.track(tracker)
        }
    }
    
    public func getSPTracker() -> SPTracker {
        return tracker
    }

    public func pauseTracking() {
        enabled = false
    }

    public func resumeTracking() {
        enabled = false
    }
    
    public func isTracking() -> Bool {
        return enabled
    }
}
