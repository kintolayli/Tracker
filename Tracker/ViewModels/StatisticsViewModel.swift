//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 30.11.2024.
//

import CoreData

final class StatisticsViewModel: StatisticsViewModelProtocol {
    
    private let context: NSManagedObjectContext
    private lazy var trackerRecordStore: TrackerRecordStore = {
        TrackerRecordStore(context: context)
    }()
    
    private lazy var trackerStore: TrackerStore = {
        TrackerStore(context: context)
    }()
    
    var data: [(String, Int)] = []
    private(set) var recordsCount: Int = 0 {
        didSet {
            onDataUpdated?()
        }
    }
    
    func isEmptyStatistics() -> Bool {
        var isEmpty = true
        
        for item in data {
            if item.1 != 0 {
                isEmpty = false
            }
        }
        
        return isEmpty
    }
    
    var onDataUpdated: (() -> Void)?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        trackerRecordStore.onRecordsChanged = { [weak self] in
            self?.fetchStatisticsData()
        }
        
        reloadData()
    }
    
    private func fetchStatisticsData() {
        
        let bestPeriodCount = calculateBestPeriod()
        let perfectDaysCount = calculatePerfectDays()
        let averageHabitsCount = calculateAverageHabitsPerDay()
        recordsCount = trackerRecordStore.records.count
        
        let bestPeriodString = L10n.StatisticsViewModel.FetchStatisticsData.bestPeriodString
        let perfectDaysString = L10n.StatisticsViewModel.FetchStatisticsData.perfectDaysString
        let trackersCompletedString = L10n.StatisticsViewModel.FetchStatisticsData.trackersCompleted
        let averageHabitsString = L10n.StatisticsViewModel.FetchStatisticsData.averageHabitsString
        
        data = [
            (bestPeriodString, bestPeriodCount),
            (perfectDaysString, perfectDaysCount),
            (trackersCompletedString, recordsCount),
            (averageHabitsString, averageHabitsCount),
        ]
    }
    
    private func calculateBestPeriod() -> Int {
        guard let allTrackers = try? trackerStore.fetchAllTrackers() else { return -1 }
        var bestPeriod = 0
        
        for tracker in allTrackers {
            guard let records = try? trackerRecordStore.getTrackerRecords(with: tracker.id) else {
                continue
            }
            
            let sortedRecords = records.sorted { $0.date < $1.date }
            
            var currentStreak = 0
            var maxStreak = 0
            var lastDate: Date?
            
            for record in sortedRecords {
                if let previousDate = lastDate {
                    let daysBetween = Calendar.current.dateComponents([.day], from: previousDate, to: record.date).day ?? 0
                    
                    if daysBetween == 1 {
                        currentStreak += 1
                    } else if daysBetween > 1 {
                        currentStreak = 0
                    }
                }
                
                maxStreak = max(maxStreak, currentStreak)
                lastDate = record.date
            }
            
            bestPeriod = max(bestPeriod, maxStreak + 1)
        }
        
        return bestPeriod
    }
    
    private func calculatePerfectDays() -> Int {
        let allTrackers = try? trackerStore.fetchAllTrackers()
        let allRecords = Array(trackerRecordStore.records)
        
        let recordsByDate = Dictionary(grouping: allRecords, by: { Calendar.current.startOfDay(for: $0.date) })
        
        var perfectDaysCount = 0
        
        for (date, records) in recordsByDate {
            
            let weekday = Calendar.current.component(.weekday, from: date)
            let dayName = DayLocalizeModel.dayName(for: weekday)
            
            let scheduledTrackers = allTrackers?.filter { tracker in
                guard let schedule = tracker.schedule else { return false }
                return schedule.contains(where: { $0.name == dayName })
            }
            
            guard let scheduledTrackers = scheduledTrackers else { return 0 }
            
            if scheduledTrackers.count > 0 && scheduledTrackers.count == records.count {
                perfectDaysCount += 1
            }
        }
        
        return perfectDaysCount
    }
    
    private func calculateAverageHabitsPerDay() -> Int {
        let allRecords = Array(trackerRecordStore.records)
        let recordsByDate = Dictionary(grouping: allRecords, by: { Calendar.current.startOfDay(for: $0.date) })
        
        let totalHabits = recordsByDate.values.reduce(0) { $0 + $1.count }
        let totalDays = recordsByDate.keys.count
        
        guard totalDays > 0 else { return 0 }
        
        return Int(Double(totalHabits) / Double(totalDays))
    }
    
    private func reloadData() {
        fetchStatisticsData()
    }
    
    func getItem(at index: Int) -> (String, Int)? {
        guard index >= 0 && index < data.count else { return nil }
        return data[index]
    }
}
