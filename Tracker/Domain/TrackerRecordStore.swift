//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Ilya Lotnik on 20.08.2024.
//

import UIKit
import CoreData

enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidDate
    case updateTrackerRecordError
    case removeTrackerRecordError
    case getTrackerRecordsWithCurrentTrackerIdError
}

struct TrackerRecordStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

//protocol TrackerRecordStoreDelegate: AnyObject {
//    func recordStore(
//        _ store: TrackerRecordStore,
//        didUpdate update: TrackerRecordStoreUpdate
//    )
//}

final class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
//    weak var delegate: TrackerRecordStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerRecordStoreUpdate.Move>?
    
    private var trackerStore: TrackerStore
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
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
    
//    var records: [UUID: [String: TrackerRecord]] {
    var records: Set<TrackerRecord> {
        guard let objects = self.fetchedResultsController.fetchedObjects,
              let recordsCoreData = try? objects.map({ try convertToTrackerRecord(from: $0) }) else { return [] }
        
        return Set(recordsCoreData)
        
//        guard let objects = self.fetchedResultsController.fetchedObjects else { return [:] }
//        
//        var result: [UUID: [String: TrackerRecord]] = [:]
//        
//        for object in objects {
//            if let convertedRecord = try? convertToTrackerRecord(from: object) {
//                for (id, dateDict) in convertedRecord {
//                    if result[id] == nil {
////                        result[id] = [:]
//                        result = convertedRecord
//                    }
//                    result[id]?.merge(dateDict) { (_, new) in new }
//                }
//            }
//        }
//        
//        
//        return result
    }
    
//    private func convertToTrackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> [UUID: [String: TrackerRecord]] {
//        guard let id = trackerRecordCoreData.id else { throw TrackerRecordStoreError.decodingErrorInvalidId }
//        guard let date = trackerRecordCoreData.date else { throw TrackerRecordStoreError.decodingErrorInvalidDate }
//        
//        let newTrackerRecord = TrackerRecord(id: id, date: date)
//        let dateAsDictKey = dateFormatter.string(from: date)
//        
//        let newRecordDay = [dateAsDictKey: newTrackerRecord]
//        let newRecordCard = [id: newRecordDay]
//        return newRecordCard
//    }
    
//    private func convertToTrackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> [UUID: [String: TrackerRecord]] {
    private func convertToTrackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.id else { throw TrackerRecordStoreError.decodingErrorInvalidId }
        guard let date = trackerRecordCoreData.date else { throw TrackerRecordStoreError.decodingErrorInvalidDate }
        
        return TrackerRecord(id: id, date: date)
//        let dateAsDictKey = dateFormatter.string(from: date)
        
//        return [id: [dateAsDictKey: newTrackerRecord]]
    }
    
//    func fetchRecords() throws -> [TrackerRecord] {
//        let fetchRequest = TrackerRecordCoreData.fetchRequest()
//        fetchRequest.returnsObjectsAsFaults = false
//        let recordsCoreData = try context.fetch(fetchRequest)
//        return try recordsCoreData.map { try convertToTrackerRecord(from: $0) }
//    }
    
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
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {}

//extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        insertedIndexes = IndexSet()
//        deletedIndexes = IndexSet()
//        updatedIndexes = IndexSet()
//        movedIndexes = Set<TrackerRecordStoreUpdate.Move>()
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        delegate?.recordStore(
//            self,
//            didUpdate: TrackerRecordStoreUpdate(
//                insertedIndexes: insertedIndexes!,
//                deletedIndexes: deletedIndexes!,
//                updatedIndexes: updatedIndexes!,
//                movedIndexes: movedIndexes!
//            )
//        )
//        insertedIndexes = nil
//        deletedIndexes = nil
//        updatedIndexes = nil
//        movedIndexes = nil
//    }
//    
//    func controller(
//        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
//        didChange anObject: Any,
//        at indexPath: IndexPath?,
//        for type: NSFetchedResultsChangeType,
//        newIndexPath: IndexPath?
//    ) {
//        switch type {
//        case .insert:
//            guard let indexPath = newIndexPath else { fatalError() }
//            insertedIndexes?.insert(indexPath.item)
//        case .delete:
//            guard let indexPath = indexPath else { fatalError() }
//            deletedIndexes?.insert(indexPath.item)
//        case .update:
//            guard let indexPath = indexPath else { fatalError() }
//            updatedIndexes?.insert(indexPath.item)
//        case .move:
//            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
//            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
//        @unknown default:
//            fatalError()
//        }
//    }
//}
