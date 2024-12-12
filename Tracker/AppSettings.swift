//
//  AppSettings.swift
//  Tracker
//
//  Created by Ilya Lotnik on 21.11.2024.
//

import Foundation

private enum Keys {
    static let isOnboardingHidden = "isOnboardingHidden"
}


final class AppSettings {
    static let shared = AppSettings()
    private let userDefaults: UserDefaults

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var isOnboardiingHidden: Bool {
        get {
            userDefaults.bool(forKey: Keys.isOnboardingHidden)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.isOnboardingHidden)
        }
    }
}
