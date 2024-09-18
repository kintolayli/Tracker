//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Ilya Lotnik on 17.09.2024.
//
//

import Foundation
import CoreData


extension TrackerCoreData {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
    
    @NSManaged public var color: String?
    @NSManaged public var emojii: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var scheduleData: Data?
    @NSManaged public var trackerCategory: TrackerCategoryCoreData?
    
    var schedule: [Day]? {
        get {
            guard let data = scheduleData else { return nil }
            return try? JSONDecoder().decode([Day].self, from: data)
        }
        set {
            scheduleData = try? JSONEncoder().encode(newValue)
        }
    }
}

extension TrackerCoreData : Identifiable {
    
}
