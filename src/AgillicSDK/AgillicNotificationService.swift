//
//  AgillicNotificationService.swift
//  AgillicSamplePushServiceExtension
//
//  Created by Simon Elhøj Steinmejer on 26/01/2022.
//

import Foundation
import UserNotifications

internal class AgillicNotificationService {
    var request: UNNotificationRequest?
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    public func process(request: UNNotificationRequest, contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.request = request
        self.contentHandler = contentHandler
        self.setImageAsAttachment()
    }

    public func serviceExtensionTimeWillExpire() {

        defer { clean() }

        // Try to call content handler with current content
        if let content = self.bestAttemptContent {
            self.contentHandler?(content)
        }
    }

    internal func setImageAsAttachment() {
        self.bestAttemptContent = (request?.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = self.bestAttemptContent, let request = self.request else { return }

        if let attachment = request.attachment {
            bestAttemptContent.attachments = [attachment]
        }

        self.finish()
    }

    func finish() {
        if let content = self.bestAttemptContent {
            self.contentHandler?(content)
        }
        
        self.clean()
    }

    internal func clean() {
        self.request = nil
        self.contentHandler = nil
        self.bestAttemptContent = nil
    }
}

internal extension UNNotificationRequest {
    var attachment: UNNotificationAttachment? {
        guard let attachmentURL = content.userInfo["image"] as? String, let imageData = try? Data(contentsOf: URL(string: attachmentURL)!) else {
            return nil
        }
        return try? UNNotificationAttachment(data: imageData, options: nil)
    }
}

internal extension UNNotificationAttachment {

    convenience init(data: Data, options: [NSObject: AnyObject]?) throws {
        let fileManager = FileManager.default
        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
        let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)

        try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)
        let imageFileIdentifier = UUID().uuidString + ".png"
        let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier)
        try data.write(to: fileURL)
        try self.init(identifier: imageFileIdentifier, url: fileURL, options: options)
    }
}
