//
//  TrackerRecordStoreError.swift
//  Tracker
//
//  Created by Ilya Lotnik on 28.09.2024.
//

import Foundation


enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidDate
    case updateTrackerRecordError
    case removeTrackerRecordError
    case getTrackerRecordsWithCurrentTrackerIdError
    case loadContextError
    case initError
}
