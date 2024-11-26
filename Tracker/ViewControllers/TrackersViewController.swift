//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 04.08.2024.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    var chooseTypeTrackerDelegate: ChooseTypeTrackerViewControllerProtocol? { get set }
    var visibleCategories: [TrackerCategory] { get set }
    var trackerCategoryStore: TrackerCategoryStore { get }
    func add(trackerCategory: TrackerCategory)
    func updateCollectionView()
}

final class TrackersViewController: UIViewController & TrackersViewControllerProtocol {
    
    weak var chooseTypeTrackerDelegate: ChooseTypeTrackerViewControllerProtocol?
    
    private lazy var params: GeometricParams = {
        let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
        return params
    }()
    
    private var currentDate: Date = Date()
    private var sectionCount: Int = 0
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    lazy var trackerCategoryStore: TrackerCategoryStore = {
        guard let context = context else {
            assertionFailure(TrackersViewControllerError.loadContextError.localizedDescription)
            
            let fallbackContext = DefaultContext(concurrencyType: .mainQueueConcurrencyType)
            return TrackerCategoryStore(context: fallbackContext)
        }
        return TrackerCategoryStore(context: context)
    }()
    
    private lazy var trackerRecordStore: TrackerRecordStore = {
        guard let context = context else {
            assertionFailure(TrackersViewControllerError.loadContextError.localizedDescription)
            
            let fallbackContext = DefaultContext(concurrencyType: .mainQueueConcurrencyType)
            return TrackerRecordStore(context: fallbackContext)
        }
        return TrackerRecordStore(context: context)
    }()
    
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    var visibleCategories: [TrackerCategory] = []
    
    private var trackerRecords = Set<TrackerRecord>()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("trackersViewController.searchBar.placeholder", comment:"Search bar placeholder")
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "dizzy")
        return view
    }()
    
    private lazy var imageViewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = NSLocalizedString("trackersViewController.imageViewLabel.text", comment:"Start screen label with empty trackers")
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCollectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        trackerCategoryStore.delegate = self
        
        visibleCategories = trackerCategoryStore.categories
        trackerRecords = trackerRecordStore.records
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        let datePicker = UIDatePicker()
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
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
        
        navigationItem.title = NSLocalizedString("trackersViewController.navigationItem.title", comment:"Page title")
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
        let trackerCategoryWithNonEmptyTrackerList = filteredCategories.filter { !$0.trackerList.isEmpty }
        
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
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        updateCollectionView()
    }
    
    func add(trackerCategory: TrackerCategory) {
        
        try? trackerCategoryStore.updateTrackerCategory(trackerCategory)
        hideImageViewIfTrackerIsNotEmpty()
    }
    
    private func getDayOfWeekFromDate(date: Date) -> String {
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date).capitalized
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    private func filterCategories(for dayOfWeek: String) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        
        for category in visibleCategories {
            var filteredTrackers: [Tracker] = []
            
            for tracker in category.trackerList {
                if let schedule = tracker.schedule {
                    for day in schedule {
                        if day.name == dayOfWeek && day.isActive {
                            filteredTrackers.append(tracker)
                            break
                        }
                    }
                } else {
                    guard let recordsFromCurrentCell = try? trackerRecordStore.getTrackerRecordsWithCurrentTrackerId(with: tracker.id) else { return [] }
                    
                    if recordsFromCurrentCell.count > 0 {
                        if (checkExistsRecord(in: recordsFromCurrentCell, with: currentDate) != nil) {
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
        return filteredCategories[section].trackerList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackersCollectionViewCell else { return UICollectionViewCell() }
        cell.prepareForReuse()
        cell.delegate = self
        
        let newCell = filteredCategories[indexPath.section].trackerList[indexPath.row]
        let (count, addButtonState) = getRecordsCountAndButtonLabelState(indexPath: indexPath)
        
        cell.updateCell(cell: newCell,
                        count: count,
                        addButtonState: addButtonState,
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
        
        if visibleCategories.count > 0 {
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
            view.updateLabel(text: visibleCategories[indexPath.section].title)
            return view
        } else {
            return UICollectionReusableView()
        }
        
    }
    
    func updateCollectionView() {
        let dayOfWeekString = getDayOfWeekFromDate(date: currentDate)
        filteredCategories = filterCategories(for: dayOfWeekString)
        collectionView.reloadData()
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
    
    func getRecordsCountAndButtonLabelState(indexPath: IndexPath) -> (Int, Bool) {
        let newCell = filteredCategories[indexPath.section].trackerList[indexPath.row]
        
        var cellCount = 0
        var cellState = false
        
        if let recordsFromCurrentCell = try? trackerRecordStore.getTrackerRecordsWithCurrentTrackerId(with: newCell.id) {
            cellCount = recordsFromCurrentCell.count
            
            if (checkExistsRecord(in: recordsFromCurrentCell, with: currentDate) != nil) {
                cellState = true
            }
        }
        
        return (cellCount, cellState)
    }
    
    private func areSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        
        let day1 = calendar.component(.day, from: date1)
        let month1 = calendar.component(.month, from: date1)
        let year1 = calendar.component(.year, from: date1)
        
        let day2 = calendar.component(.day, from: date2)
        let month2 = calendar.component(.month, from: date2)
        let year2 = calendar.component(.year, from: date2)
        
        return day1 == day2 && month1 == month2 && year1 == year2
    }
    
    private func checkExistsRecord(in records: [TrackerRecord], with date: Date) -> TrackerRecord? {
        var resultRecord: TrackerRecord?
        
        for record in records {
            if areSameDay(date1: record.date, date2: date) {
                resultRecord = record
            }
        }
        return resultRecord
    }
    
    func trackersViewControllerCellTap(_ cell: TrackersCollectionViewCell) {
        if currentDate <= Date() {
            guard let indexPath = collectionView.indexPath(for: cell)  else { return }
            let tracker = filteredCategories[indexPath.section].trackerList[indexPath.row]
            guard let recordsFromCurrentCell = try? trackerRecordStore.getTrackerRecordsWithCurrentTrackerId(with: tracker.id) else { return }
            
            if let existRecord = checkExistsRecord(in: recordsFromCurrentCell, with: currentDate) {
                try? trackerRecordStore.removeTrackerRecord(existRecord)
                cell.updateButtonState(count: recordsFromCurrentCell.count - 1, state: false, schedule: tracker.schedule)
            } else {
                let newTrackerRecord = TrackerRecord(id: UUID(), date: currentDate)
                try? trackerRecordStore.addTrackerRecord(newTrackerRecord, trackerId: tracker.id)
                cell.updateButtonState(count: recordsFromCurrentCell.count + 1, state: true, schedule: tracker.schedule)
            }
        } else {
            let alertModel = AlertModel(
                title: NSLocalizedString("trackersViewController.trackersViewControllerCellTap.alertModel.title", comment: "Alert title"),
                message: NSLocalizedString("trackersViewController.trackersViewControllerCellTap.alertModel.message", comment: "Alert message"),
                buttonTitle: NSLocalizedString("trackersViewController.trackersViewControllerCellTap.alertModel.buttonTitle", comment: "Alert button title"),
                buttonAction: nil
            )
            AlertPresenter.show(model: alertModel, viewController: self)
        }
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    
    private func addNewSectionIfNeeded() {
        if collectionView.numberOfSections != filteredCategories.count {
            
            let newSectionIndex = filteredCategories.count - 1
            collectionView.insertSections(IndexSet(integer: newSectionIndex))
        }
    }
    
    func categoryStore(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        visibleCategories = trackerCategoryStore.categories
        let dayOfWeekString = getDayOfWeekFromDate(date: currentDate)
        let oldFilteredTrackerListCount = filteredCategories.first?.trackerList.count ?? 0
        filteredCategories = filterCategories(for: dayOfWeekString)
        guard let filteredTrackerListCount = filteredCategories.first?.trackerList.count else { return }
        
        if filteredTrackerListCount > oldFilteredTrackerListCount {
            collectionView.reloadData()
        }
    }
}
