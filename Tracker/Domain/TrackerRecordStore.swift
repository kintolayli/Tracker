//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Ilya Lotnik on 20.08.2024.
//

import CoreData


final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    private var trackerStore: TrackerStore
    var onRecordsChanged: (() -> Void)?

    init(context: NSManagedObjectContext) {
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
        do {
            try controller.performFetch()
        } catch {
            assertionFailure(TrackerRecordStoreError.performFetchError.localizedDescription)
        }
    }

    var records: Set<TrackerRecord> {
        let objects = self.fetchedResultsController?.fetchedObjects
        let recordsCoreData = try? objects?.compactMap { try convertToTrackerRecord(from: $0) }

        return Set(recordsCoreData ?? [])
    }

    private func convertToTrackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.id else { throw TrackerRecordStoreError.decodingErrorInvalidId }
        guard let date = trackerRecordCoreData.date else { throw TrackerRecordStoreError.decodingErrorInvalidDate }

        return TrackerRecord(id: id, date: date)
    }

    func getTrackerRecords(with trackerId: UUID) throws -> [TrackerRecord] {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)

        if let trackerRecords = try? context.fetch(fetchRequest) {
            let recordsFromCurrentTracker = try trackerRecords.map { try convertToTrackerRecord(from: $0) }
            return recordsFromCurrentTracker
        } else {
            throw TrackerRecordStoreError.getTrackerRecordsWithCurrentTrackerIdError
        }
    }

    func getTrackerRecordsCoreData(with trackerId: UUID) throws -> [TrackerRecordCoreData] {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)

        if let trackerRecords = try? context.fetch(fetchRequest) {
            return trackerRecords
        } else {
            throw TrackerRecordStoreError.getTrackerRecordsWithCurrentTrackerIdError
        }
    }

    func isExistTrackerRecord(with trackerId: UUID, currentDate: Date) -> Bool {
        var cellState = false

        if let recordsFromCurrentCell = try? getTrackerRecords(with: trackerId) {
            if (checkExistsRecord(in: recordsFromCurrentCell, with: currentDate) != nil) {
                cellState = true
            }
        }
        return cellState
    }

    private func checkExistsRecord(in records: [TrackerRecord], with date: Date) -> TrackerRecord? {
        var resultRecord: TrackerRecord?

        for record in records {
            if isSameDay(date1: record.date, date2: date) {
                resultRecord = record
            }
        }
        return resultRecord
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

    func removeAllTrackerRecord(with trackerId: UUID) {
        guard let trackersRecords = try? getTrackerRecords(with: trackerId) else { return }
        for record in trackersRecords {
            try? removeTrackerRecord(record)
        }
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

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onRecordsChanged?()
    }
}
