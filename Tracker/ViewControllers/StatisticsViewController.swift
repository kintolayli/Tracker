//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 04.08.2024.
//

import UIKit

final class StatisticsViewController: UIViewController, StatisticsViewControllerDelegate {
    
    private let data: [(String, Int)] = [
        ("Лучший период", 6),
        ("Идеальные дни", 2),
        ("Трекеров завершено", 5),
        ("Среднее значение", 4),
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.masksToBounds = true
        
        tableView.allowsSelection = true
        tableView.register(StatisticsTableViewCell.self, forCellReuseIdentifier: StatisticsTableViewCell.reuseIdentifier)
        tableView.separatorColor = .ypGray
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = false
        tableView.backgroundColor = .ypMainBackground
        
        return tableView
    }()
    
    private lazy var imageViewEmptyState: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "3")
        return view
    }()
    
    private lazy var imageViewLabelEmptyState: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = NSLocalizedString("statisticsViewController.imageViewLabel.text", comment:"Start screen label with empty statistics")
        return label
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypMainBackground
        navigationItem.title = NSLocalizedString("statisticsViewController.navigationItem.title", comment:"Page title")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            imageViewEmptyState,
            imageViewLabelEmptyState,
            tableView
        ])
        
        NSLayoutConstraint.activate([
            imageViewEmptyState.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageViewEmptyState.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageViewLabelEmptyState.topAnchor.constraint(equalTo: imageViewEmptyState.bottomAnchor, constant: 8),
            imageViewLabelEmptyState.centerXAnchor.constraint(equalTo: imageViewEmptyState.centerXAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func updateEmptyStateViewVisibility() {
        let isTrackerListEmpty = data.isEmpty
        
        imageViewEmptyState.isHidden = !isTrackerListEmpty
        imageViewLabelEmptyState.isHidden = !isTrackerListEmpty
    }
    
    private func updateTableView() {
        tableView.reloadData()
        updateEmptyStateViewVisibility()
    }
}


extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.reuseIdentifier, for: indexPath) as? StatisticsTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        
        let text = data[indexPath.row].0
        let count = data[indexPath.row].1
        
        cell.configure(with: (text, count))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
