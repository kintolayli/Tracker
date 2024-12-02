//
//  DayLocalizeModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 26.11.2024.
//

import Foundation

enum DayLocalizeModel {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var fullDayName: String {
        switch self {
        case .monday:
            return L10n.DayLocalizeModel.FullDayName.monday
        case .tuesday:
            return L10n.DayLocalizeModel.FullDayName.tuesday
        case .wednesday:
            return L10n.DayLocalizeModel.FullDayName.wednesday
        case .thursday:
            return L10n.DayLocalizeModel.FullDayName.thursday
        case .friday:
            return L10n.DayLocalizeModel.FullDayName.friday
        case .saturday:
            return L10n.DayLocalizeModel.FullDayName.saturday
        case .sunday:
            return L10n.DayLocalizeModel.FullDayName.sunday
        }
    }
    
    var shortDayName: String {
        switch self {
        case .monday:
            return L10n.DayLocalizeModel.ShortDayName.monday
        case .tuesday:
            return L10n.DayLocalizeModel.ShortDayName.tuesday
        case .wednesday:
            return L10n.DayLocalizeModel.ShortDayName.wednesday
        case .thursday:
            return L10n.DayLocalizeModel.ShortDayName.thursday
        case .friday:
            return L10n.DayLocalizeModel.ShortDayName.friday
        case .saturday:
            return L10n.DayLocalizeModel.ShortDayName.saturday
        case .sunday:
            return L10n.DayLocalizeModel.ShortDayName.sunday
        }
    }
}

extension DayLocalizeModel {
    static func dayName(for weekday: Int) -> String {
        switch weekday {
        case 1: return sunday.fullDayName
        case 2: return monday.fullDayName
        case 3: return tuesday.fullDayName
        case 4: return wednesday.fullDayName
        case 5: return thursday.fullDayName
        case 6: return friday.fullDayName
        case 7: return saturday.fullDayName
        default: return ""
        }
    }
}
