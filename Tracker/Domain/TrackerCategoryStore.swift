//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Ilya Lotnik on 20.08.2024.
//

import CoreData


protocol TrackerCategoryStoreDelegate: AnyObject {
    func categoryStore(
        _ store: TrackerCategoryStore,
        didUpdate update: TrackerCategoryStoreUpdate
    )
}

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    var currentDate: Date?
    
    weak var delegate: TrackerCategoryStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    private var trackerStore: TrackerStore
    private var trackerRecordStore: TrackerRecordStore
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
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
            assertionFailure(TrackerCategoryStoreError.performFetchError.localizedDescription)
        }
    }
    
    var categories: [TrackerCategory] {
        guard let objects = self.fetchedResultsController?.fetchedObjects,
              let categoriesCoreData = try? objects.map({ try convertToTrackerCategory(from: $0) }) else { return [] }
        return categoriesCoreData
    }
    
    var pinnedCategories: [TrackerCategory] {
        
        guard let pinnedTrackers = try? trackerStore.fetchPinnedTrackers() else { return [] }
        
        let pinnedCategoryTitle = NSLocalizedString("trackersViewController.pinTracker.pinnedCategoryTitle", comment: "Title pinned category")
        let pinnedCategory = TrackerCategory(title: pinnedCategoryTitle, trackerList: pinnedTrackers)
        
        let unpinnedCategories = categories.map { category in
            TrackerCategory(title: category.title, trackerList: category.trackerList.filter { !$0.isPinned })
        }.filter { category in
            !(category.trackerList.count == 1 && category.trackerList.first?.isPinned == true)
        }
        
        return [pinnedCategory] + unpinnedCategories
    }
    
    var completedCategories: [TrackerCategory] {
        let allCategories = categories
        
        let completedCategoriesList = allCategories.map { category in
            TrackerCategory(
                title: category.title,
                trackerList: category.trackerList.filter { tracker in
                    (tracker.schedule == nil) && isTrackerCompleted(tracker)
                }
            )
        }
        
        return completedCategoriesList.filter { !$0.trackerList.isEmpty }
    }
    
    var notCompletedCategories: [TrackerCategory] {

        let allCategories = categories

        let notCompletedCategoriesList = allCategories.map { category in
            TrackerCategory(
                title: category.title,
                trackerList: category.trackerList.filter { tracker in
                    (tracker.schedule == nil) && !isTrackerCompleted(tracker)
                }
            )
        }
        return notCompletedCategoriesList.filter { !$0.trackerList.isEmpty }
    }
    
    func isTrackerCompleted(_ tracker: Tracker) -> Bool {
        guard let date = currentDate else {
            assertionFailure( "Current date is nil when checking tracker completion")
            return false
        }
        return trackerRecordStore.isExistTrackerRecord(with: tracker.id, currentDate: date)
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        let categoriesCoreData = try context.fetch(fetchRequest)
        return try categoriesCoreData.map { try convertToTrackerCategory(from: $0) }
    }
    
    private func convertToTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        
        guard let title = trackerCategoryCoreData.title else { throw TrackerCategoryStoreError.decodingErrorInvalidTitle }
        guard let trackerListCoreData = trackerCategoryCoreData.trackerList?.allObjects as? [TrackerCoreData] else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackerList
        }
        
        let trackerList = try trackerListCoreData.map { try trackerStore.convertToTracker(from: $0) }
        return TrackerCategory(title: title, trackerList: trackerList)
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        for tracker in category.trackerList {
            try trackerStore.addTracker(with: categoryCoreData, with: tracker)
        }
    }
    
    func updateTrackerCategoryTitle(newName: String, oldName: String) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", oldName)
        
        let categories = try context.fetch(fetchRequest)
        
        if let categoryToUpdate = categories.first {
            categoryToUpdate.title = newName
        }
        saveContext()
    }

    func updateTrackerCategory(_ category: TrackerCategory) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        let categories = try context.fetch(fetchRequest)
        
        if let categoryToUpdate = categories.first {
            for tracker in category.trackerList {
                trackerStore.updateTracker(with: categoryToUpdate, with: tracker)
            }
        } else {
            try addCategory(category)
        }
        saveContext()
    }
    
    func deleteCategory(with title: String) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        let categories = try context.fetch(fetchRequest)
        
        if let categoryToRemove = categories.first {
            context.delete(categoryToRemove)
            try context.save()
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


extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.categoryStore(
            self,
            didUpdate: TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes ?? IndexSet(),
                updatedIndexes: updatedIndexes ?? IndexSet(),
                movedIndexes: movedIndexes ?? Set()
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes?.insert(newIndexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexes?.insert(indexPath.item)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
            }
        @unknown default:
            assertionFailure("Unhandled case in switch: \(type)")
        }
    }
}
