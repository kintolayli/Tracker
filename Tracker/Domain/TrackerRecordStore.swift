//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Ilya Lotnik on 20.08.2024.
//

import UIKit
import CoreData


final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    private var trackerStore: TrackerStore
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    convenience override init() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { fatalError(TrackerRecordStoreError.loadContextError.localizedDescription)}
        do {
            try self.init(context: context)
        } catch {
            fatalError(TrackerRecordStoreError.initError.localizedDescription)
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        trackerStore = TrackerStore(context: context)
        super.init()
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    var records: Set<TrackerRecord> {
        guard let objects = self.fetchedResultsController?.fetchedObjects,
              let recordsCoreData = try? objects.map({ try convertToTrackerRecord(from: $0) }) else { return [] }
        
        return Set(recordsCoreData)
    }
    
    private func convertToTrackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.id else { throw TrackerRecordStoreError.decodingErrorInvalidId }
        guard let date = trackerRecordCoreData.date else { throw TrackerRecordStoreError.decodingErrorInvalidDate }
        
        return TrackerRecord(id: id, date: date)
    }
    
    func getTrackerRecordsWithCurrentTrackerId(with trackerId: UUID) throws -> [TrackerRecord] {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        
        if let trackerRecords = try? context.fetch(fetchRequest) {
            let recordsFromCurrentTracker = try trackerRecords.map({ try convertToTrackerRecord(from: $0) })
            return recordsFromCurrentTracker
        } else {
            throw TrackerRecordStoreError.getTrackerRecordsWithCurrentTrackerIdError
        }
    }
    
    func addTrackerRecord(_ trackerRecord: TrackerRecord, trackerId: UUID) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
        
        let currentTracker = try? trackerStore.getTrackerById(with: trackerId)
        trackerRecordCoreData.tracker = currentTracker
        
        saveContext()
    }
    
    func removeTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerRecord.id as CVarArg)
        
        if let trackerRecordCoreData = try context.fetch(fetchRequest).first {
            context.delete(trackerRecordCoreData)
            saveContext()
        } else {
            throw TrackerRecordStoreError.removeTrackerRecordError
        }
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
