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

    func testViewController() {
        let vc = TrackersViewController()
        
        assertSnapshot(matching: vc, as: .image)
    }

}
