//
//  SheduleViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 10.08.2024.
//

import UIKit


protocol SheduleViewControllerProtocol: AnyObject {
    var createEventTrackerViewController: CreateEventTrackerViewController? { get set }
    func getShedule() -> [Day]
}

final class SheduleViewController: UIViewController, SheduleViewControllerProtocol {
    
    weak var createEventTrackerViewController: CreateEventTrackerViewController?
    
    private var days: [Day] = [
        .init(name: "Понедельник", isActive: false, abbreviation: "Пн"),
        .init(name: "Вторник", isActive: false, abbreviation: "Вт"),
        .init(name: "Среда", isActive: false, abbreviation: "Ср"),
        .init(name: "Четверг", isActive: false, abbreviation: "Чт"),
        .init(name: "Пятница", isActive: false, abbreviation: "Пт"),
        .init(name: "Суббота", isActive: false, abbreviation: "Сб"),
        .init(name: "Воскресенье", isActive: false, abbreviation: "Вс")
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Расписание"
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.register(SheduleTableViewCell.self, forCellReuseIdentifier: SheduleTableViewCell.reuseIdentifier)
        
        return tableView
    }()
    
    private let okButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            titleLabel,
            tableView,
            okButton,
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            okButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            okButton.heightAnchor.constraint(equalToConstant: 60),
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        okButton.addTarget(self, action: #selector(okButtonDidTap), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc private func okButtonDidTap() {
        dismiss(animated: true)
    }
    
    func getShedule() -> [Day] {
        return days
    }
}

extension SheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SheduleTableViewCell.reuseIdentifier, for: indexPath) as? SheduleTableViewCell else { return UITableViewCell() }
        
        cell.prepareForReuse()
        cell.delegate = self
        
        let day = days[indexPath.row]
        cell.configure(with: day)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? BaseTableViewCell else { return }
        cell.roundedCornersAndOffLastSeparatorVisibility(indexPath: indexPath, tableView: tableView)
    }
}

extension SheduleViewController: SheduleTableViewCellDelegate {
    
    func switchValueChanged(isOn: Bool, cell: SheduleTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            days[indexPath.row].isActive = isOn
        }
        
        let selectedDaysString = shortStringFromSelectedDays()
        createEventTrackerViewController?.didSelectDays(selectedDaysString)
        createEventTrackerViewController?.updateTableViewSecondCell()
        createEventTrackerViewController?.scheduleDidChange()
    }
    
    private func shortStringFromSelectedDays() -> String {
        var daysArray: [String] = []
        
        for day in days {
            if day.isActive {
                daysArray.append(day.abbreviation)
            }
        }
        
        if daysArray.count == 7 {
            daysArray = []
            daysArray.append("Каждый день")
        }
        
        return daysArray.joined(separator: ", ")
    }
    
    func updateDays(from string: String) {
        if string == "Каждый день" {
            for i in 0..<days.count {
                days[i].isActive = true
            }
        } else {
            let shortDaysArray = string.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
            for i in 0..<days.count {
                if shortDaysArray.contains(days[i].abbreviation) {
                    days[i].isActive = true
                }
            }
        }
    }
}
