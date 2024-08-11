//
//  CreateRegularEventTrackerViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 08.08.2024.
//

import UIKit

protocol CreateRegularEventTrackerViewControllerProtocol: AnyObject {
    var viewController: ChooseTypeTrackerViewControllerProtocol? { get set }
    var categoryListdelegate: CategoryListViewControllerProtocol? { get set }
    var sheduleDelegate: SheduleViewControllerProtocol? { get set }
    func didSelectCategory(_ category: String)
    func didSelectDays(_ daysString: String)
    func updateTableViewFirstCell()
    func updateTableViewSecondCell()
}

final class CreateRegularEventTrackerViewController: UIViewController, CreateRegularEventTrackerViewControllerProtocol {
    
    var viewController: ChooseTypeTrackerViewControllerProtocol?
    var categoryListdelegate: CategoryListViewControllerProtocol?
    var sheduleDelegate: SheduleViewControllerProtocol?
    lazy var selectedCategory: String = menuSecondaryItems[0][0]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Новая привычка"
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.textAlignment = .center
        textField.maxLength = 38
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RegularEventTrackerCell")
        
        return tableView
    }()
    
    private let menuItems: [String] = [
        "Категория",
        "Расписание"
    ]
    private var menuSecondaryItems: [[String]] = [
        [""],
        [""]
    ]
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let menuSecondaryItemFirst = viewController?.viewController?.categories.first else { return }
        menuSecondaryItems[0] = [menuSecondaryItemFirst.title]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            titleLabel,
            textField,
            tableView,
            cancelButton,
            createButton
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            textField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 172),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 172),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonDidTap), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(categoryDidChange), name: .categoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleDidChange), name: .scheduleDidChange, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func updateTableViewFirstCell() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let text = menuItems[indexPath.row]
        let secondaryText = menuSecondaryItems[indexPath.row][0]
        
        if #available(iOS 14.0, *) {
            var content = UIListContentConfiguration.cell()
            content.text = text
            content.secondaryText = secondaryText
            content.textProperties.font = .systemFont(ofSize: 17, weight: .regular)
            content.textProperties.color = .ypBlack
            content.secondaryTextProperties.font = .systemFont(ofSize: 17, weight: .regular)
            content.secondaryTextProperties.color = .ypGray
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = text
            cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.textLabel?.textColor = .ypBlack
            cell.detailTextLabel?.text = secondaryText
            cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.detailTextLabel?.textColor = .ypGray
        }
        
        tableView.reloadData()
    }
    
    func updateTableViewSecondCell() {
        let indexPath = IndexPath(row: 1, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let secondaryText = menuSecondaryItems[indexPath.row][0]
        
        if #available(iOS 14.0, *) {
            var content = UIListContentConfiguration.cell()
            content.secondaryText = secondaryText
            content.textProperties.font = .systemFont(ofSize: 17, weight: .regular)
            content.textProperties.color = .ypBlack
            content.secondaryTextProperties.font = .systemFont(ofSize: 17, weight: .regular)
            content.secondaryTextProperties.color = .ypGray
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.textLabel?.textColor = .ypBlack
            cell.detailTextLabel?.text = secondaryText
            cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.detailTextLabel?.textColor = .ypGray
        }
        
        tableView.reloadData()
    }
    
    func didSelectCategory(_ category: String) {
        menuSecondaryItems[0] = [category]
        selectedCategory = category
    }
    
    func didSelectDays(_ daysString: String) {
        menuSecondaryItems[1] = [daysString]
    }
    
    func updateCreateButtonState() {
        let isCategoryEmpty = menuSecondaryItems[0][0] == ""
        let isSheduleEmpty = menuSecondaryItems[1][0] == ""
        
        guard let isTextFieldEmpty = textField.text?.isEmpty else { return }
        
        createButton.isEnabled = !isTextFieldEmpty && !isCategoryEmpty && !isSheduleEmpty
        createButton.backgroundColor = createButton.isEnabled ? .ypBlack : .ypGray
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    @objc func categoryDidChange() {
        updateCreateButtonState()
    }
    
    @objc func scheduleDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonDidTap() {
        
        let emojies = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
        
        let colors: [UIColor] = [
            .ypColorSelection1,
            .ypColorSelection2,
            .ypColorSelection3,
            .ypColorSelection4,
            .ypColorSelection5,
            .ypColorSelection6,
            .ypColorSelection7,
            .ypColorSelection8,
            .ypColorSelection9,
            .ypColorSelection10,
            .ypColorSelection11,
            .ypColorSelection12,
            .ypColorSelection13,
            .ypColorSelection14,
            .ypColorSelection15,
            .ypColorSelection16,
            .ypColorSelection17,
            .ypColorSelection18,
        ]
        
        guard let name = textField.text else { return }
        
        let randomIntColors = Int.random(in: 0..<colors.count)
        let color = colors[randomIntColors]
        
        let randomIntEmojies = Int.random(in: 0..<emojies.count)
        let emojii = emojies[randomIntEmojies]
        
        guard let shedule = sheduleDelegate?.getShedule() else { return }
        let newTracker = Tracker(name: name, color: color, emojii: emojii, schedule: shedule)
        let category = selectedCategory
        
        let newTrackerCategory = TrackerCategory(title: category, trackerList: [newTracker])
        
        self.viewController?.viewController?.add(trackerCategory: newTrackerCategory)
        self.dismiss(animated: true)
        self.viewController?.dismiss(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CreateRegularEventTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegularEventTrackerCell", for: indexPath)
        
        cell.prepareForReuse()
        
        cell.backgroundColor = .ypBackground
        cell.accessoryType = .disclosureIndicator
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let text = menuItems[indexPath.row]
        let secondaryText = menuSecondaryItems[indexPath.row][0]
        
        if #available(iOS 14.0, *) {
            var content = UIListContentConfiguration.cell()
            content.text = text
            content.secondaryText = secondaryText
            content.textProperties.font = .systemFont(ofSize: 17, weight: .regular)
            content.textProperties.color = .ypBlack
            content.secondaryTextProperties.font = .systemFont(ofSize: 17, weight: .regular)
            content.secondaryTextProperties.color = .ypGray
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = text
            cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.textLabel?.textColor = .ypBlack
            cell.detailTextLabel?.text = secondaryText
            cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.detailTextLabel?.textColor = .ypGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 1.99
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let viewController = CategoryListViewController()
            viewController.viewController = self
            viewController.selectedCategory = selectedCategory
            categoryListdelegate = viewController
            viewController.modalPresentationStyle = .formSheet
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        } else {
            let viewController = SheduleViewController()
            viewController.viewController = self
            viewController.updateDays(from: menuSecondaryItems[1][0])
            sheduleDelegate = viewController
            viewController.modalPresentationStyle = .formSheet
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        }
    }
}
