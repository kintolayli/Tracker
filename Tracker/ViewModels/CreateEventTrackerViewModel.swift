//
//  CreateEventTrackerViewModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 03.12.2024.
//

import UIKit


final class CreateEventTrackerViewModel: CreateEventTrackerViewModelProtocol {
    let emojies = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    let colors: [UIColor] = [
        .ypColorSelection1,
        .ypColorSelection2,
        .ypColorSelection3,
        .ypColorSelection4,
        .ypColorSelection5,
        .ypColorSelection6,
        .ypColorSelection7,
        .ypColorSelection8,
        .ypColorSelection9,
        .ypColorSelection10,
        .ypColorSelection11,
        .ypColorSelection12,
        .ypColorSelection13,
        .ypColorSelection14,
        .ypColorSelection15,
        .ypColorSelection16,
        .ypColorSelection17,
        .ypColorSelection18
    ]
    var selectedCategory: String?
    var schedule: [Day]?
    var selectedEmojii: String?
    var selectedColor: UIColor?

    let params: GeometricParams = {
        let params = GeometricParams(cellCount: 6, leftInset: 16, rightInset: 16, cellSpacing: 6)
        return params
    }()

    var menuItems: [String] = [
        L10n.CreateEventTrackerViewController.MenuItems.item1
    ]
    var menuSecondaryItems: [[String]] = [[""], [""]]

    func didSelectCategory(_ category: String) {
        menuSecondaryItems[0][0] = category
        selectedCategory = category
    }

    func didSelectDays(_ daysString: String) {
        menuSecondaryItems[1][0] = daysString
    }
}
