//
//  TrackerStore.swift
//  Tracker
//
//  Created by Ilya Lotnik on 20.08.2024.
//

import CoreData


final class TrackerStore {
    
    private let context: NSManagedObjectContext
    private let daysValueTransformer = DaysValueTransformer()
    private lazy var recordStore = TrackerRecordStore(context: context)
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchPinnedTrackers() throws -> [Tracker] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "isPinned == true")
        
        let trackersCoreData = try context.fetch(fetchRequest)
        return try trackersCoreData.map { try convertToTracker(from: $0) }
    }
    
    func addTracker(with categoryCoreData: TrackerCategoryCoreData, with tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emojii = tracker.emojii
        trackerCoreData.schedule = tracker.schedule
        
        trackerCoreData.trackerCategory = categoryCoreData
        categoryCoreData.addToTrackerList(trackerCoreData)
    }
    
    
    func updateTracker(with categoryCoreData: TrackerCategoryCoreData, with tracker: Tracker) {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let existingTracker = try? context.fetch(fetchRequest).first {
            existingTracker.name = tracker.name
            existingTracker.color = UIColorMarshalling.hexString(from: tracker.color)
            existingTracker.emojii = tracker.emojii
            existingTracker.schedule = tracker.schedule
            existingTracker.trackerCategory = categoryCoreData
            
            saveContext()
        } else {
            try? addTracker(with: categoryCoreData, with: tracker)
            saveContext()
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
    
    func removeTracker(withId trackerId: UUID) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            context.delete(trackerCoreData)
            saveContext()
        } else {
            throw TrackerStoreError.deleteTrackerError
        }
    }
    
    func togglePinTracker(withId trackerId: UUID) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            trackerCoreData.isPinned = !trackerCoreData.isPinned
            saveContext()
        } else {
            throw TrackerStoreError.pinTrackerError
        }
    }
    
    func convertToTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else { throw TrackerStoreError.decodingErrorInvalidId }
        guard let name = trackerCoreData.name else { throw TrackerStoreError.decodingErrorInvalidName }
        guard let emojii = trackerCoreData.emojii else { throw TrackerStoreError.decodingErrorInvalidEmojii }
        guard let colorHex = trackerCoreData.color else { throw TrackerStoreError.decodingErrorInvalidColor }
        let isPinned = trackerCoreData.isPinned
        let schedule = trackerCoreData.schedule
        
        return Tracker(
            id: id,
            name: name,
            color: UIColorMarshalling.color(from: colorHex),
            emojii: emojii,
            schedule: schedule,
            isPinned: isPinned
        )
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("Save context error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
