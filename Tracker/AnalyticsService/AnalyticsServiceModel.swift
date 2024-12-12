//
//  AnalyticsServiceBaseModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 30.11.2024.
//

enum AnalyticsServiceModel {
    enum Event: String {
        case open
        case close
        case click

        static var rawValue: String {
            return "event"
        }
    }

    enum Screen: String {
        case main

        static var rawValue: String {
            return "screen"
        }
    }

    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete

        static var rawValue: String {
            return "item"
        }
    }
}
