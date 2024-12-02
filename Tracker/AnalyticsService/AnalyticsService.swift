//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Ilya Lotnik on 30.11.2024.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    
    static let event = AnalyticsServiceModel.Event.self
    static let screen = AnalyticsServiceModel.Screen.self
    static let item = AnalyticsServiceModel.Item.self
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "09574d69-8f60-484c-bee6-8bb3e585cc77") else { return }
        configuration.areLogsEnabled = true
        
        AppMetrica.activate(with: configuration)
    }
    
    static func report(params: [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: "EVENT", parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
    
    static func openScreen() {

        report(params: [
            event.rawValue: event.open.rawValue,
            screen.rawValue: screen.main.rawValue
        ])
    }
    
    static func closeScreen() {
        
        report(params: [
            event.rawValue: event.close.rawValue,
            screen.rawValue: screen.main.rawValue
        ])
    }
    
    static func didTapAddTrackerButton() {
        
        report(params: [
            event.rawValue: event.click.rawValue,
            screen.rawValue: screen.main.rawValue,
            item.rawValue: item.addTrack.rawValue,
        ])
    }
    
    static func clickTracker() {

        report(params: [
            event.rawValue: event.click.rawValue,
            screen.rawValue: screen.main.rawValue,
            item.rawValue: item.track.rawValue,
        ])
    }
    
    static func clickFilter() {

        report(params: [
            event.rawValue: event.click.rawValue,
            screen.rawValue: screen.main.rawValue,
            item.rawValue: item.filter.rawValue,
        ])
    }
    
    static func selectContextMenuEdit() {

        report(params: [
            event.rawValue: event.click.rawValue,
            screen.rawValue: screen.main.rawValue,
            item.rawValue: item.edit.rawValue,
        ])
    }
    
    static func selectContextMenuDelete() {

        report(params: [
            event.rawValue: event.click.rawValue,
            screen.rawValue: screen.main.rawValue,
            item.rawValue: item.delete.rawValue,
        ])
    }
}
