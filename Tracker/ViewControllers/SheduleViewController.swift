//
//  SheduleViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 10.08.2024.
//

import UIKit


protocol SheduleViewControllerProtocol: AnyObject {
    var viewController: CreateRegularEventTrackerViewController? { get set }
}

class SheduleViewController: UIViewController, SheduleViewControllerProtocol{
    
    var viewController: CreateRegularEventTrackerViewController?
    
    private var days: [(String, Bool, String)] = [
        ("Понедельник", false, "Пн"),
        ("Вторник", false, "Вт"),
        ("Среда", false, "Ср"),
        ("Четверг", false, "Чт"),
        ("Пятница", false, "Пт"),
        ("Суббота", false, "Сб"),
        ("Воскресенье", false, "Вс")
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
}

extension SheduleViewController: SheduleTableViewCellDelegate {
    func switchValueChanged(isOn: Bool, cell: SheduleTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            days[indexPath.row].1 = isOn
        }
        
        let selectedDaysString = shortStringFromSelectedDays()
        viewController?.didSelectDays(selectedDaysString)
        viewController?.updateTableViewSecondCell()
        viewController?.scheduleDidChange()
    }
    
    private func shortStringFromSelectedDays() -> String {
        var daysArray: [String] = []
        
        for day in days {
            if day.1 {
                daysArray.append(day.2)
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
                days[i].1 = true
            }
        } else {
            let shortDaysArray = string.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
            for i in 0..<days.count {
                if shortDaysArray.contains(days[i].2) {
                    days[i].1 = true
                }
            }
        }
    }
}
