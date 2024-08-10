//
//  TabBarController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 04.08.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    private enum TabBarItem: Int {
        case tracker
        case statistics
        
        var title: String {
            switch self {
            case .tracker:
                return "Трекеры"
            case .statistics:
                return "Статистика"
            }
        }
        
        var iconName: String {
            switch self {
            case .tracker:
                return "record.circle.fill"
            case .statistics:
                return "hare.fill"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let dataSource: [TabBarItem] = [.tracker, .statistics]
        tabBar.backgroundColor = .ypWhite
        
        tabBar.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        tabBar.layer.shadowRadius = 0.5
        
        viewControllers = dataSource.map {
            switch $0 {
            case .tracker:
                let trackerViewController = TrackersViewController()
                return UINavigationController(rootViewController: trackerViewController)
            case .statistics:
                let statisticsViewController = StatisticsViewController()
                return UINavigationController(rootViewController: statisticsViewController)
            }
        }
        viewControllers?.enumerated().forEach {
            $1.tabBarItem.title = dataSource[$0].title
            $1.tabBarItem.image = UIImage(systemName: dataSource[$0].iconName)
        }
    }
    
}
