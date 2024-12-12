//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Ilya Lotnik on 30.11.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testViewControllerLightTheme() {
        let viewController = TrackersViewController()

        assertSnapshot(matching: viewController, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testViewControllerDarkTheme() {
        let viewController = TrackersViewController()

        assertSnapshot(matching: viewController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
