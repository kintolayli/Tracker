//
//  TrackerStoreError.swift
//  Tracker
//
//  Created by Ilya Lotnik on 28.09.2024.
//

import Foundation


enum TrackerStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidName
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmojii
    case decodingErrorInvalidShedule
    case deleteTrackerError
    case pinTrackerError
    case unpinTrackerError
    case updateTrackerError
    case getTrackerCoreDataError
    case loadContextError
    case initError
}
