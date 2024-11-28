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
            return NSLocalizedString("trackerFilterItems.filterName.alltrackers",
                                                        comment:"Filter title")
        case .todayTrackers:
            return NSLocalizedString("trackerFilterItems.filterName.todayTrackers",
                                                        comment:"Filter title")
        case .completed:
            return NSLocalizedString("trackerFilterItems.filterName.completed",
                                                        comment:"Filter title")
        case .notCompleted:
            return NSLocalizedString("trackerFilterItems.filterName.notCompleted",
                                                        comment:"Filter title")
        }
    }
}
