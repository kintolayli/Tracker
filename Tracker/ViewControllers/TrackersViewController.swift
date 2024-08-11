//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 04.08.2024.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    var delegate: ChooseTypeTrackerViewControllerProtocol? { get set }
    var categories: [TrackerCategory] { get set }
    func add(trackerCategory: TrackerCategory)
}

final class TrackersViewController: UIViewController & TrackersViewControllerProtocol {
    
    weak var delegate: ChooseTypeTrackerViewControllerProtocol?
    
    private let params: GeometricParams = {
        let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
        return params
    }()
    
    //    var categories: [TrackerCategory] = [
    //        TrackerCategory(title: "По умолчанию", trackerList: []),
    //    ]
    
    var filteredCategories: [TrackerCategory] = []
    var categories: [TrackerCategory] = [
        TrackerCategory(title: "Домашний уют", trackerList: [
            Tracker(name: "Поливать растения", color: .ypColorSelection10, emojii: "🍇", schedule: [
                ("Понедельник", true, "Пн"),
                ("Вторник", false, "Вт"),
                ("Среда", false, "Ср"),
                ("Четверг", false, "Чт"),
                ("Пятница", false, "Пт"),
                ("Суббота", false, "Сб"),
                ("Воскресенье", false, "Вс")
            ]),
            Tracker(name: "Сходить погулять", color: .ypColorSelection2, emojii: "🫒", schedule: [
                ("Понедельник", false, "Пн"),
                ("Вторник", true, "Вт"),
                ("Среда", false, "Ср"),
                ("Четверг", false, "Чт"),
                ("Пятница", false, "Пт"),
                ("Суббота", false, "Сб"),
                ("Воскресенье", false, "Вс")
            ]),
            Tracker(name: "Выкинуть мусор", color: .ypColorSelection13, emojii: "🍆", schedule: [
                ("Понедельник", false, "Пн"),
                ("Вторник", false, "Вт"),
                ("Среда", true, "Ср"),
                ("Четверг", false, "Чт"),
                ("Пятница", false, "Пт"),
                ("Суббота", false, "Сб"),
                ("Воскресенье", false, "Вс")
            ]),
        ]),
        TrackerCategory(title: "Радостные мелочи", trackerList: [
            Tracker(name: "Кошка заслонила камеру на созвоне", color: .ypColorSelection17, emojii: "🥑", schedule: [
                ("Понедельник", false, "Пн"),
                ("Вторник", false, "Вт"),
                ("Среда", true, "Ср"),
                ("Четверг", true, "Чт"),
                ("Пятница", false, "Пт"),
                ("Суббота", false, "Сб"),
                ("Воскресенье", false, "Вс")
            ]),
            Tracker(name: "Бабушка прислала открытку в вотсапе", color: .ypColorSelection18, emojii: "🫑", schedule: [
                ("Понедельник", false, "Пн"),
                ("Вторник", false, "Вт"),
                ("Среда", false, "Ср"),
                ("Четверг", false, "Чт"),
                ("Пятница", true, "Пт"),
                ("Суббота", false, "Сб"),
                ("Воскресенье", false, "Вс")
            ]),
            Tracker(name: "Свидания в апреле", color: .ypColorSelection9, emojii: "🥒", schedule: [
                ("Понедельник", false, "Пн"),
                ("Вторник", false, "Вт"),
                ("Среда", false, "Ср"),
                ("Четверг", false, "Чт"),
                ("Пятница", false, "Пт"),
                ("Суббота", true, "Сб"),
                ("Воскресенье", true, "Вс")
            ]),
        ]),
        TrackerCategory(title: "Самочувствие", trackerList: [
            Tracker(name: "Хорошее настроение", color: .ypColorSelection14, emojii: "🥝", schedule: [
                ("Понедельник", false, "Пн"),
                ("Вторник", false, "Вт"),
                ("Среда", false, "Ср"),
                ("Четверг", false, "Чт"),
                ("Пятница", false, "Пт"),
                ("Суббота", false, "Сб"),
                ("Воскресенье", true, "Вс")
            ]),
            Tracker(name: "Легкая тревожность", color: .ypColorSelection15, emojii: "🙂", schedule: [
                ("Понедельник", false, "Пн"),
                ("Вторник", false, "Вт"),
                ("Среда", true, "Ср"),
                ("Четверг", false, "Чт"),
                ("Пятница", false, "Пт"),
                ("Суббота", false, "Сб"),
                ("Воскресенье", false, "Вс")
            ]),
        ]),
    ]
    
    private var completedTrackers: [UUID: TrackerRecord] = [:]
    private var currentDate: Date = Date()
    private var sectionCount: Int = 0
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "dizzy")
        return view
    }()
    
    private let imageViewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = "Что будем отслеживать?"
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideImageViewIfTrackerIsNotEmpty()
        
        let dayOfWeekString = getDayOfWeekFromDate()
        updateCollectionView(selectedDate: dayOfWeekString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        let addTrackerButton = UIButton(type: .custom)
        addTrackerButton.setBackgroundImage(UIImage(named: "addTracker"), for: .normal)
        addTrackerButton.addTarget(self, action: #selector(didTapTrackerButton), for: .touchUpInside)
        addTrackerButton.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        buttonView.bounds = buttonView.bounds.offsetBy(dx: 10, dy: 0)
        buttonView.addSubview(addTrackerButton)
        let addButton = UIBarButtonItem(customView: buttonView)
        navigationItem.leftBarButtonItem = addButton
        
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            searchBar,
            collectionView,
            imageView,
            imageViewLabel
        ])
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageViewLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            imageViewLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    private func hideImageViewIfTrackerIsNotEmpty() {
        let trackerCategoryWithNonEmptyTrackerList = categories.filter { !$0.trackerList.isEmpty }
        
        if trackerCategoryWithNonEmptyTrackerList.count == 0 {
            imageView.isHidden = false
            imageViewLabel.isHidden = false
        } else {
            imageView.isHidden = true
            imageViewLabel.isHidden = true
        }
    }
    
    @objc private func didTapTrackerButton() {
        let viewController = ChooseTypeTrackerViewController()
        viewController.viewController = self
        delegate = viewController
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        let formattedDate = getDayOfWeekFromDate()
        updateCollectionView(selectedDate: formattedDate)
    }
    
    func add(trackerCategory: TrackerCategory) {
        var oldTrackerCategory: TrackerCategory?
        var oldTrackerCategoryIndex: Int?
        let updatedTrackerList: [Tracker]
        
        for (index, category) in categories.enumerated() {
            if category.title == trackerCategory.title {
                oldTrackerCategoryIndex = index
                oldTrackerCategory = category
            }
        }
        
        guard let oldTrackerCategory else { return }
        updatedTrackerList = trackerCategory.trackerList + oldTrackerCategory.trackerList
        let updatedTrackerCategory = TrackerCategory(title: trackerCategory.title, trackerList: updatedTrackerList)
        guard let oldTrackerCategoryIndex else { return }
        categories[oldTrackerCategoryIndex] = updatedTrackerCategory
        
        hideImageViewIfTrackerIsNotEmpty()
        
        let dayOfWeekString = getDayOfWeekFromDate()
        filteredCategories = filterCategories(for: dayOfWeekString)
        
        let trackerDayOfTheWeek = trackerCategory.trackerList[0].schedule.first(where: { $0.0 == dayOfWeekString && $0.1 })
        if trackerDayOfTheWeek?.0 == dayOfWeekString {
            
            collectionView.performBatchUpdates {
                let newTrackerCategoryIndex = filteredCategories.firstIndex { $0.title == trackerCategory.title } ?? filteredCategories.count - 1
                
                if sectionCount != filteredCategories.count {
                    sectionCount = filteredCategories.count
                    collectionView.insertSections(IndexSet(integer: newTrackerCategoryIndex))
                }
                
                let indexes = IndexPath(row: 0, section: newTrackerCategoryIndex)
                collectionView.insertItems(at: [indexes])
            }
        }
    }
    
    func getDayOfWeekFromDate() -> String {
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: currentDate).capitalized
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func filterCategories(for dayOfWeek: String) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        
        for category in categories {
            var filteredTrackers: [Tracker] = []
            
            for tracker in category.trackerList {
                for day in tracker.schedule {
                    let dayName = day.0
                    let isActive = day.1
                    
                    if dayName == dayOfWeek && isActive {
                        filteredTrackers.append(tracker)
                        break
                    }
                }
            }
            
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(title: category.title, trackerList: filteredTrackers)
                filteredCategories.append(filteredCategory)
            }
        }
        
        return filteredCategories
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackerList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackersCollectionViewCell else { fatalError("cell did not initialize") }
        cell.prepareForReuse()
        cell.delegate = self
        
        let newCell = filteredCategories[indexPath.section].trackerList[indexPath.row]
        
        cell.updateCell(backgroundColor: newCell.color,
                        emojiiLabelText: newCell.emojii,
                        titleLabelText: newCell.name,
                        isPin: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
        view.titleLabel.text = categories[indexPath.section].title
        view.titleLabel.text = filteredCategories[indexPath.section].title
        return view
    }
    
    func updateCollectionView(selectedDate: String) {
        filteredCategories = filterCategories(for: selectedDate)
        collectionView.reloadData()
        sectionCount = filteredCategories.count
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: params.leftInset, bottom: 10, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        if !categories[section].trackerList.isEmpty{
            return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        } else {
            return CGSize()
        }
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    
    func trackersViewControllerCellTap(_ cell: TrackersCollectionViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell)  else { return }
        let newCell = categories[indexPath.section].trackerList[indexPath.row]
        let newTrackerRecord = TrackerRecord(id: newCell.id)
        
        if completedTrackers.keys.contains(where: { $0 == newCell.id }) {
            guard let dateComplete = completedTrackers[newCell.id]?.date else { return }
            let dateString1 = dateFormatter.string(from: dateComplete)
            let dateString2 = dateFormatter.string(from: currentDate)
            
            if dateString1 == dateString2 {
                completedTrackers.removeValue(forKey: newCell.id)
                cell.decreaseCounter()
            } else {
                completedTrackers.updateValue(newTrackerRecord, forKey: newCell.id)
                cell.increaseCounter()
            }
        } else {
            completedTrackers.updateValue(newTrackerRecord, forKey: newCell.id)
            cell.increaseCounter()
        }
    }
}
