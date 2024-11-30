//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Ilya Lotnik on 30.11.2024.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    
    let event = AnalyticsServiceModel.Event.self
    let screen = AnalyticsServiceModel.Screen.self
    let item = AnalyticsServiceModel.Item.self
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "09574d69-8f60-484c-bee6-8bb3e585cc77") else { return }
        configuration.areLogsEnabled = true
        
        AppMetrica.activate(with: configuration)
    }
    
    func report(params: [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: "EVENT", parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
    
    func openScreen() {

        report(params: [
            event.rawValue: event.open.rawValue,
            screen.rawValue: screen.main.rawValue
        ])
    }
    
    func closeScreen() {
        
        report(params: [
            event.rawValue: event.close.rawValue,
            screen.rawValue: screen.main.rawValue
        ])
    }
    
    func didTapAddTrackerButton() {
        
        report(params: [
            event.rawValue: event.click.rawValue,
            screen.rawValue: screen.main.rawValue,
            item.rawValue: item.addTrack.rawValue,
        ])
    }
    
    func clickTracker() {

        report(params: [
            event.rawValue: event.click.rawValue,
            screen.rawValue: screen.main.rawValue,
            item.rawValue: item.track.rawValue,
        ])
    }
    
    func clickFilter() {

        report(params: [
            event.rawValue: event.click.rawValue,
            screen.rawValue: screen.main.rawValue,
            item.rawValue: item.filter.rawValue,
        ])
    }
    
    func selectContextMenuEdit() {

        report(params: [
            event.rawValue: event.click.rawValue,
            screen.rawValue: screen.main.rawValue,
            item.rawValue: item.edit.rawValue,
        ])
    }
    
    func selectContextMenuDelete() {

        report(params: [
            event.rawValue: event.click.rawValue,
            screen.rawValue: screen.main.rawValue,
            item.rawValue: item.delete.rawValue,
        ])
    }
}
