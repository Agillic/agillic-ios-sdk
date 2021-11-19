//
//  AgillicRequestCallback.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

import Foundation

internal protocol AgillicRequestCallback {
    
    func onSuccess(withCount successCount: Int)
    func onFailure(withCount failureCount: Int, successCount: Int)
}
