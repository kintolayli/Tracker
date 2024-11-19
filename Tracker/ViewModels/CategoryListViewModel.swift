//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 18.11.2024.
//

import Foundation

typealias Binding<T> = (T) -> Void



final class CategoryListViewModel {
    var categories: [TrackerCategory] = []
    var didFetchCategories: Binding<[TrackerCategory]>?
    var didSelectCategoryHandler: Binding<String>?
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    init() {
        fetchCategories()
    }
    
    func fetchCategories() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
            didFetchCategories?(categories as [TrackerCategory])
        } catch {
            print("Ошибка загрузки категорий: \(error)")
        }
    }
    
    func saveCategory(text: String) {
        let newCategory = TrackerCategory(title: text, trackerList: [])
        
        do {
            try trackerCategoryStore.updateTrackerCategory(newCategory)
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
}
