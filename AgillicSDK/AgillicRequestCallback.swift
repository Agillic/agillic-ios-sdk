//
//  AgillicRequestCallback.swift
//  AgillicSDK
//
//  Created by Dennis Schafroth on 24/06/2020.
//  Copyright © 2020 Agillic. All rights reserved.
//

import Foundation

public protocol AgillicRequestCallback {
    
    func onSuccess(withCount successCount: Int)
    func onFailure(withCount failureCount: Int, successCount: Int)
}
