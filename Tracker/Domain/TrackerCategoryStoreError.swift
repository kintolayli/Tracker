//
//  TrackerCategoryStoreError.swift
//  Tracker
//
//  Created by Ilya Lotnik on 28.09.2024.
//

import Foundation


enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTrackerList
    case updateTrackerCategoryError
    case removeTrackerCategoryError
    case loadContextError
    case initErro
    case performFetchError
}
