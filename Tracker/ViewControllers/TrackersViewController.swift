//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 04.08.2024.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    var chooseTypeTrackerDelegate: ChooseTypeTrackerViewControllerProtocol? { get set }
    //    var categories: [TrackerCategory] { get set }
    var visibleCategories: [TrackerCategory] { get set }
    func add(trackerCategory: TrackerCategory)
}

final class TrackersViewController: UIViewController & TrackersViewControllerProtocol {
    
    weak var chooseTypeTrackerDelegate: ChooseTypeTrackerViewControllerProtocol?
    
    private let params: GeometricParams = {
        let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
        return params
    }()
    
    private var currentDate: Date = Date()
    private var sectionCount: Int = 0
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    var categories: [TrackerCategory] = []
    var filteredCategories: [TrackerCategory] = []
    var visibleCategories: [TrackerCategory] = []
    
//    private var completedTrackers: [UUID: [String: TrackerRecord]] = [:]
    private var trackerRecords = Set<TrackerRecord>()

    private var dateFormatter: DateFormatter = {
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
        
        //        let dayOfWeekString = getDayOfWeekFromDate(date: currentDate)
        //        updateCollectionView(selectedDate: dayOfWeekString)
        hideImageViewIfTrackerIsNotEmpty()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        trackerCategoryStore.delegate = self
//        trackerRecordStore.delegate = self
        
        visibleCategories = trackerCategoryStore.categories
//        completedTrackers = trackerRecordStore.records
        trackerRecords = trackerRecordStore.records
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        let datePicker = UIDatePicker()
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
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
        //        let trackerCategoryWithNonEmptyTrackerList = filteredCategories.filter { !$0.trackerList.isEmpty }
        let trackerCategoryWithNonEmptyTrackerList = visibleCategories.filter { !$0.trackerList.isEmpty }
        
        if trackerCategoryWithNonEmptyTrackerList.isEmpty {
            imageView.isHidden = false
            imageViewLabel.isHidden = false
        } else {
            imageView.isHidden = true
            imageViewLabel.isHidden = true
        }
    }
    
    @objc private func didTapTrackerButton() {
        let viewController = ChooseTypeTrackerViewController()
        viewController.trackersViewController = self
        chooseTypeTrackerDelegate = viewController
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        //        let formattedDate = getDayOfWeekFromDate(date: currentDate)
        //        updateCollectionView(selectedDate: formattedDate)
    }
    
    //    func add(trackerCategory: TrackerCategory) {
    //        var oldTrackerCategory: TrackerCategory?
    //        var oldTrackerCategoryIndex: Int?
    //        let updatedTrackerList: [Tracker]
    //
    //        for (index, category) in visibleCategories.enumerated() {
    //            if category.title == trackerCategory.title {
    //                oldTrackerCategoryIndex = index
    //                oldTrackerCategory = category
    //            }
    //        }
    //
    //        guard let oldTrackerCategory else { return }
    //        updatedTrackerList = trackerCategory.trackerList + oldTrackerCategory.trackerList
    //        let updatedTrackerCategory = TrackerCategory(title: trackerCategory.title, trackerList: updatedTrackerList)
    //        guard let oldTrackerCategoryIndex else { return }
    //        visibleCategories[oldTrackerCategoryIndex] = updatedTrackerCategory
    //        try! trackerCategoryStore.addCategory(updatedTrackerCategory)
    //
    //        let dayOfWeekString = getDayOfWeekFromDate(date: currentDate)
    //        filteredCategories = filterCategories(for: dayOfWeekString)
    //
    //        if (trackerCategory.trackerList[0].schedule?.first(where: { $0.name == dayOfWeekString && $0.isActive })) != nil {
    //            cellPerformBatchUpdates(trackerCategory)
    //        }
    //
    //        if trackerCategory.trackerList[0].schedule == nil {
    //            cellPerformBatchUpdates(trackerCategory)
    //        }
    //
    //        hideImageViewIfTrackerIsNotEmpty()
    //    }
    
    func add(trackerCategory: TrackerCategory) {
        
        try? trackerCategoryStore.updateTrackerCategory(trackerCategory)
        //        try! trackerCategoryStore.addCategory(trackerCategory)
        hideImageViewIfTrackerIsNotEmpty()
    }
    
    func cellPerformBatchUpdates(_ trackerCategory: TrackerCategory) {
        collectionView.performBatchUpdates {
            //            let newTrackerCategoryIndex = filteredCategories.firstIndex { $0.title == trackerCategory.title } ?? filteredCategories.count - 1
            let newTrackerCategoryIndex = visibleCategories.firstIndex { $0.title == trackerCategory.title } ?? filteredCategories.count - 1
            
            if sectionCount != visibleCategories.count {
                sectionCount = visibleCategories.count
                collectionView.insertSections(IndexSet(integer: newTrackerCategoryIndex))
            }
            
            let indexes = IndexPath(row: 0, section: newTrackerCategoryIndex)
            collectionView.insertItems(at: [indexes])
        }
    }
    
    func getDayOfWeekFromDate(date: Date) -> String {
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date).capitalized
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func filterCategories(for dayOfWeek: String) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        
        for category in visibleCategories {
            var filteredTrackers: [Tracker] = []
            
            for tracker in category.trackerList {
                if let schedule = tracker.schedule {
                    for day in schedule {
                        let dayName = day.name
                        let isActive = day.isActive
                        
                        if dayName == dayOfWeek && isActive {
                            filteredTrackers.append(tracker)
                            break
                        }
                    }
                } else {
                    dateFormatter.dateFormat = "dd.MM.yyyy"
                    let todayDate = dateFormatter.string(from: currentDate)
                    
                    if let completeDateString = isIrregularTrackerComplete(id: tracker.id) {
                        if todayDate == completeDateString {
                            filteredTrackers.append(tracker)
                        }
                    } else {
                        filteredTrackers.append(tracker)
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
        //        return filteredCategories[section].trackerList.count
        return visibleCategories[section].trackerList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //        return sectionCount
        //        return 1
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackersCollectionViewCell else { return UICollectionViewCell() }
        cell.prepareForReuse()
        cell.delegate = self
        
        //        let newCell = filteredCategories[indexPath.section].trackerList[indexPath.row]
        let newCell = visibleCategories[indexPath.section].trackerList[indexPath.row]
        let (count, addButtonState) = getRecordsCountAndButtonLabelState(indexPath: indexPath)
        
        cell.updateCell(backgroundColor: newCell.color,
                        emojiiLabelText: newCell.emojii,
                        titleLabelText: newCell.name,
                        count: count,
                        addButtonState: addButtonState,
                        isPin: false,
                        isIrregularTracker: newCell.schedule == nil)
        
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
        //        view.titleLabel.text = filteredCategories[indexPath.section].title
        view.titleLabel.text = visibleCategories[indexPath.section].title
        return view
    }
    
    func updateCollectionView(selectedDate: String) {
        //        filteredCategories = filterCategories(for: selectedDate)
        visibleCategories = filterCategories(for: selectedDate)
        collectionView.reloadData()
        //        sectionCount = filteredCategories.count
//        sectionCount = visibleCategories.count
        hideImageViewIfTrackerIsNotEmpty()
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    
    func isIrregularTrackerComplete(id: UUID) -> String? {
        var completedDate: String?
        
//        if completedTrackers.keys.contains(where: { $0 == id }) {
//            guard let trackerRecords = completedTrackers[id] else { return nil }
//            guard let completed = trackerRecords.first?.value else { return nil }
//            
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            completedDate = dateFormatter.string(from: completed.date)
//        }
        return completedDate
    }
    
    func getRecordsCountAndButtonLabelState(indexPath: IndexPath) -> (Int, Bool) {
        //        let newCell = filteredCategories[indexPath.section].trackerList[indexPath.row]
        let newCell = visibleCategories[indexPath.section].trackerList[indexPath.row]
        
        var cellCount = 0
        var cellState = false
        
        if let recordsFromCurrentCell = try? trackerRecordStore.getTrackerRecordsWithCurrentTrackerId(with: newCell.id) {
            cellCount = recordsFromCurrentCell.count
            
            for record in recordsFromCurrentCell {
                if areSameDay(date1: record.date, date2: currentDate) {
                    cellState = true
                }
            }
            
        }
            
        return (cellCount, cellState)
    }
    
    func areSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        
        let day1 = calendar.component(.day, from: date1)
        let month1 = calendar.component(.month, from: date1)
        let year1 = calendar.component(.year, from: date1)
        
        let day2 = calendar.component(.day, from: date2)
        let month2 = calendar.component(.month, from: date2)
        let year2 = calendar.component(.year, from: date2)
        
        return day1 == day2 && month1 == month2 && year1 == year2
    }
    
    func trackersViewControllerCellTap(_ cell: TrackersCollectionViewCell) {
        if currentDate <= Date() {
            guard let indexPath = collectionView.indexPath(for: cell)  else { return }
            
            //            let newCell = filteredCategories[indexPath.section].trackerList[indexPath.row]
            let newCell = visibleCategories[indexPath.section].trackerList[indexPath.row]
            var cellState = false
            
            guard let recordsFromcurrentCell = try? trackerRecordStore.getTrackerRecordsWithCurrentTrackerId(with: newCell.id) else { return }
            
            if recordsFromcurrentCell.count > 0 {
                for record in recordsFromcurrentCell {
                    if areSameDay(date1: record.date, date2: currentDate) {
                        try? trackerRecordStore.removeTrackerRecord(record)
                        
                        let count = recordsFromcurrentCell.count - 1
                        cell.updateButtonState(count: count, state: cellState, isIrregularTracker: newCell.schedule == nil)
                    }
                }
            } else {
                let newTrackerRecord = TrackerRecord(id: UUID(), date: currentDate)
                try? trackerRecordStore.addTrackerRecord(newTrackerRecord, trackerId: newCell.id)
                let count = recordsFromcurrentCell.count + 1
                cellState = true
                cell.updateButtonState(count: count, state: cellState, isIrregularTracker: newCell.schedule == nil)
            }
        } else {
            let alertModel = AlertModel(title: "Уведомление от системы", message: "Нельзя отметить карточку для будущей даты", buttonTitle: "ОК", buttonAction: nil)
            AlertPresenter.show(model: alertModel, viewController: self)
        }
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func categoryStore(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        visibleCategories = trackerCategoryStore.categories
        collectionView.performBatchUpdates {
            
            if collectionView.numberOfSections == 0 {
                collectionView.insertSections(IndexSet(integer: 0))
            }
            
            //            let newTrackerCategoryIndex = visibleCategories.count - 1
            //
            //            if sectionCount != visibleCategories.count {
            //                sectionCount = visibleCategories.count
            //                collectionView.insertSections(IndexSet(integer: newTrackerCategoryIndex))
            //            }
            
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            let updatedIndexPaths = update.updatedIndexes.map { IndexPath(item: $0, section: 0) }
            collectionView.insertItems(at: insertedIndexPaths)
            collectionView.insertItems(at: deletedIndexPaths)
            collectionView.insertItems(at: updatedIndexPaths)
            for move in update.movedIndexes {
                collectionView.moveItem(
                    at: IndexPath(item: move.oldIndex, section: 0),
                    to: IndexPath(item: move.newIndex, section: 0)
                )
            }
        }
    }
}
