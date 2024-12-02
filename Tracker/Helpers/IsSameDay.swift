//
//  IsSameDay.swift
//  Tracker
//
//  Created by Ilya Lotnik on 29.11.2024.
//

import Foundation

func isSameDay(date1: Date, date2: Date) -> Bool {
    Calendar.current.isDate(date1, inSameDayAs: date2)
}
