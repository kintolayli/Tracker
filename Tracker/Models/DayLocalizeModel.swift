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
            return NSLocalizedString("dayLocalizeModel.fullDayName.monday",
                                     comment:"Full day name of the week - Monday")
        case .tuesday:
            return NSLocalizedString("dayLocalizeModel.fullDayName.tuesday",
                                     comment:"Full day name of the week - Tuesday")
        case .wednesday:
            return NSLocalizedString("dayLocalizeModel.fullDayName.wednesday",
                                     comment:"Full day name of the week - Wednesday")
        case .thursday:
            return NSLocalizedString("dayLocalizeModel.fullDayName.thursday",
                                     comment:"Full day name of the week - Thursday")
        case .friday:
            return NSLocalizedString("dayLocalizeModel.fullDayName.friday",
                                     comment:"Full day name of the week - Friday")
        case .saturday:
            return NSLocalizedString("dayLocalizeModel.fullDayName.saturday",
                                     comment:"Full day name of the week - Saturday")
        case .sunday:
            return NSLocalizedString("dayLocalizeModel.fullDayName.sunday",
                                     comment:"Full day name of the week - Sunday")
        }
    }
    
    var shortDayName: String {
        switch self {
        case .monday:
            return NSLocalizedString("dayLocalizeModel.shortDayName.monday",
                                     comment:"Short day name of the week - Monday")
        case .tuesday:
            return NSLocalizedString("dayLocalizeModel.shortDayName.tuesday",
                                     comment:"Short day name of the week - Tuesday")
        case .wednesday:
            return NSLocalizedString("dayLocalizeModel.shortDayName.wednesday",
                                     comment:"Short day name of the week - Wednesday")
        case .thursday:
            return NSLocalizedString("dayLocalizeModel.shortDayName.thursday",
                                     comment:"Short day name of the week - Thursday")
        case .friday:
            return NSLocalizedString("dayLocalizeModel.shortDayName.friday",
                                     comment:"Short day name of the week - Friday")
        case .saturday:
            return NSLocalizedString("dayLocalizeModel.shortDayName.saturday",
                                     comment:"Short day name of the week - Saturday")
        case .sunday:
            return NSLocalizedString("dayLocalizeModel.shortDayName.sunday",
                                     comment:"Short day name of the week - Sunday")
        }
    }
}
