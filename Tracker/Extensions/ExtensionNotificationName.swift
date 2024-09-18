//
//  ExtensionNotificationName.swift
//  Tracker
//
//  Created by Ilya Lotnik on 10.08.2024.
//

import Foundation


extension Notification.Name {
    static let didAddCategory = NSNotification.Name("didAddCategory")
    static let categoryDidChange = Notification.Name("categoryDidChange")
    static let scheduleDidChange = Notification.Name("scheduleDidChange")
    static let emojiiDidChange = Notification.Name("emojiiDidChange")
    static let colorDidChange = Notification.Name("colorDidChange")
}
