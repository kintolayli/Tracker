//
//  AnalyticsServiceBaseModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 30.11.2024.
//

enum AnalyticsServiceModel {

    enum Event: String {
        case open = "open"
        case close = "close"
        case click = "click"
        
        static var rawValue:String {
            return "event"
        }
    }

    enum Screen: String {
        case main = "main"
        
        static var rawValue: String {
            return "screen"
        }
    }

    enum Item: String {
        case addTrack = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
        
        static var rawValue: String {
            return "item"
        }
    }
}
