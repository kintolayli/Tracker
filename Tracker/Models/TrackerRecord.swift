//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Ilya Lotnik on 06.08.2024.
//

import Foundation


struct TrackerRecord: Hashable {
    let id: UUID
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.id == rhs.id
    }
}
