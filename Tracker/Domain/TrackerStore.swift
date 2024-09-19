//
//  TrackerStore.swift
//  Tracker
//
//  Created by Ilya Lotnik on 20.08.2024.
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidName
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmojii
    case decodingErrorInvalidShedule
    case deleteTrackerError
    case updateTrackerError
    case getTrackerCoreDataError
}

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let daysValueTransformer = DaysValueTransformer()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        let trackersCoreData = try context.fetch(fetchRequest)
        return try trackersCoreData.map { try convertToTracker(from: $0) }
    }
    
    func addTracker(with categoryCoreData: TrackerCategoryCoreData, with tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emojii = tracker.emojii
        trackerCoreData.schedule = tracker.schedule
        
        trackerCoreData.trackerCategory = categoryCoreData
        categoryCoreData.addToTrackerList(trackerCoreData)
    }
    
    
    func updateTracker(with categoryCoreData: TrackerCategoryCoreData, with tracker: Tracker) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let existingTracker = try context.fetch(fetchRequest).first {
            existingTracker.name = tracker.name
            existingTracker.color = uiColorMarshalling.hexString(from: tracker.color)
            existingTracker.emojii = tracker.emojii
            existingTracker.schedule = tracker.schedule
            
            existingTracker.trackerCategory = categoryCoreData
            
            saveContext()
        } else {
            throw TrackerStoreError.updateTrackerError
        }
    }
    
    func getTrackerById(with trackerId: UUID) throws -> TrackerCoreData {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            return trackerCoreData
        } else {
            throw TrackerStoreError.getTrackerCoreDataError
        }
    }
    
    func removeTracker(_ tracker: Tracker) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            context.delete(trackerCoreData)
            saveContext()
        } else {
            throw TrackerStoreError.deleteTrackerError
        }
    }
    
    func convertToTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else { throw TrackerStoreError.decodingErrorInvalidId }
        guard let name = trackerCoreData.name else { throw TrackerStoreError.decodingErrorInvalidName }
        guard let emojii = trackerCoreData.emojii else { throw TrackerStoreError.decodingErrorInvalidEmojii }
        guard let colorHex = trackerCoreData.color else { throw TrackerStoreError.decodingErrorInvalidColor }
        let schedule = trackerCoreData.schedule
        
        return Tracker(
            id: id,
            name: name,
            color: uiColorMarshalling.color(from: colorHex),
            emojii: emojii,
            schedule: schedule
        )
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
