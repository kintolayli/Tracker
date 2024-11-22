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
    
    weak var delegate: TrackerCategoryStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    private var trackerStore: TrackerStore
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
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
    
    func updateTrackerCategory(_ category: TrackerCategory) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        let categories = try context.fetch(fetchRequest)
        
        if let categoryToUpdate = categories.first {
            
            for tracker in category.trackerList {
                try trackerStore.addTracker(with: categoryToUpdate, with: tracker)
            }
            
        } else {
            try addCategory(category)
        }
        saveContext()
    }
    
    func removeTrackerCategory(with title: String) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        let categories = try context.fetch(fetchRequest)
        
        if let categoryToRemove = categories.first {
            context.delete(categoryToRemove)
            try context.save()
        }
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
        case .insert, .delete, .update:
            guard let indexPath = newIndexPath else {
                assertionFailure("Invalid state: `newIndexPath` is nil for type \(type)")
                return
            }
            updatedIndexes?.insert(indexPath.item)
            
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else {
                assertionFailure("Invalid state: `indexPath` or `newIndexPath` is nil for type .move")
                return
            }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            assertionFailure("Unhandled case in switch: \(type)")
            return
        }
    }
}
