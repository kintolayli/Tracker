//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 18.11.2024.
//

import Foundation


final class CategoryListViewModel: CategoryListViewModelProtocol {
    var categories: [TrackerCategory] = []
    var didFetchCategories: Binding<[TrackerCategory]>?
    var didSelectCategoryHandler: Binding<String>?

    let trackerCategoryStore: TrackerCategoryStore
    let trackerRecordStore: TrackerRecordStore
    let trackerStore: TrackerStore

    init(trackerCategoryStore: TrackerCategoryStore, trackerStore: TrackerStore, trackerRecordStore: TrackerRecordStore) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
        fetchCategories()
    }

    func fetchCategories() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
            didFetchCategories?(categories as [TrackerCategory])
        } catch {
            print("Failed to load category: \(error)")
        }
    }

    func saveCategory(text: String, oldCategoryName: String?) {
        let newCategory = TrackerCategory(title: text, trackerList: [])

        do {
            if let oldName = oldCategoryName {
                try trackerCategoryStore.updateTrackerCategoryTitle(newName: text, oldName: oldName)
            } else {
                try trackerCategoryStore.updateTrackerCategory(newCategory)
            }
            fetchCategories()
        } catch {
            print("Failed to save category: \(error)")
        }
    }

    func didSelectCategory(_ categoryTitle: String) {
        didSelectCategoryHandler?(categoryTitle)
    }

    func saveLastSelectedCategory(selectedCategoryTitle: String) {
        UserDefaults.standard.set(selectedCategoryTitle, forKey: "lastSelectedCategory")
    }

    func deleteLastSelectedCategory(selectedCategoryTitle: String) {
        UserDefaults.standard.removeObject(forKey: "lastSelectedCategory")
    }
}
