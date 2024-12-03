//
//  TrackersFilterItems.swift
//  Tracker
//
//  Created by Ilya Lotnik on 28.11.2024.
//

import Foundation


enum TrackerFilterItems: CaseIterable {
    case allTrackers
    case todayTrackers
    case completed
    case notCompleted
    
    var filterName: String {
        switch self {
        case .allTrackers:
            return L10n.TrackerFilterItems.FilterName.alltrackers
        case .todayTrackers:
            return L10n.TrackerFilterItems.FilterName.todayTrackers
        case .completed:
            return L10n.TrackerFilterItems.FilterName.completed
        case .notCompleted:
            return L10n.TrackerFilterItems.FilterName.notCompleted
        }
    }
}
