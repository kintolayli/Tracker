//
//  Tracker.swift
//  Tracker
//
//  Created by Ilya Lotnik on 06.08.2024.
//

import UIKit


struct Tracker {
    let id: UUID = UUID()
    let name: String
    let color: UIColor
    let emojii: String
    let schedule: [(String, Bool, String)]?
}
