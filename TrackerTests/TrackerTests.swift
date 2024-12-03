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
        let vc = TrackersViewController()
        
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testViewControllerDarkTheme() {
        let vc = TrackersViewController()
        
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

}
