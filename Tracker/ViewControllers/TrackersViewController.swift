//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 04.08.2024.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    var chooseTypeTrackerDelegate: ChooseTypeTrackerViewControllerProtocol? { get set }
    var trackerCategoryStore: TrackerCategoryStore { get }
    func add(trackerCategory: TrackerCategory)
    func update(tracker: Tracker, trackerCategory: TrackerCategory)
    func updateCollectionView()
}

final class TrackersViewController: UIViewController & TrackersViewControllerProtocol {
    
    weak var chooseTypeTrackerDelegate: ChooseTypeTrackerViewControllerProtocol?
    
    private lazy var params: GeometricParams = {
        let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
        return params
    }()
    
    private var currentDate: Date = Date()
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    private lazy var trackerStore: TrackerStore = {
        guard let context = context else {
            assertionFailure(TrackersViewControllerError.loadContextError.localizedDescription)
            
            let fallbackContext = DefaultContext(concurrencyType: .mainQueueConcurrencyType)
            return TrackerStore(context: fallbackContext)
        }
        return TrackerStore(context: context)
    }()
    
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
    private var visibleCategories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
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
    
    private lazy var searchBar: UISearchTextField = {
        let searchBar = UISearchTextField()
        searchBar.placeholder = NSLocalizedString("trackersViewController.searchBar.placeholder", comment:"Search bar placeholder")
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
    
    private func updateCategoriesFromCategoryStore() {
        categories = trackerCategoryStore.pinnedCategories
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        trackerCategoryStore.delegate = self
        updateCategoriesFromCategoryStore()
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
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        searchBar.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        enableKeyboardDismissOnTap()
    }
    
    @objc private func textDidChange(_ searchField: UISearchTextField) {
        if let searchText = searchField.text, !searchText.isEmpty {
            filteredCategories = visibleCategories.compactMap { category in
                let filteredTrackers = category.trackerList.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackerList: filteredTrackers)
            }
        } else {
            filteredCategories = visibleCategories
        }
        collectionView.reloadData()
    }
    
    private func updateEmptyStateViewVisibility() {
        let nonEmptyCategories = visibleCategories.filter { !$0.trackerList.isEmpty }
        
        let isTrackerListEmpty = nonEmptyCategories.isEmpty
        
        imageView.isHidden = !isTrackerListEmpty
        imageViewLabel.isHidden = !isTrackerListEmpty
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
    
    func update(tracker: Tracker, trackerCategory: TrackerCategory) {
        try? trackerStore.removeTracker(withId: tracker.id)
        add(trackerCategory: trackerCategory)
    }
    
    func add(trackerCategory: TrackerCategory) {
        try? trackerCategoryStore.updateTrackerCategory(trackerCategory)
        updateEmptyStateViewVisibility()
    }
    
    private func getDayOfWeekFromDate(date: Date) -> String {
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date).capitalized
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    private func filterCategories(for dayOfWeek: String) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        
        for category in categories {
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
        
        cell.updateCell(cell: newCell, count: count, addButtonState: addButtonState)
        
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
        
        if filteredCategories.count > 0 {
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
            view.updateLabel(text: filteredCategories[indexPath.section].title)
            return view
        } else {
            return UICollectionReusableView()
        }
        
    }
    
    func updateCollectionView() {
        let dayOfWeekString = getDayOfWeekFromDate(date: currentDate)
        visibleCategories = filterCategories(for: dayOfWeekString)
        filteredCategories = visibleCategories
        collectionView.reloadData()
        updateEmptyStateViewVisibility()
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let indexPath = indexPaths.first else { return nil }
        let tracker = visibleCategories[indexPath.section].trackerList[indexPath.row]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            
            let pinTitle = NSLocalizedString("trackersViewController.collectionView.pinTitle", comment: "Item in the dropdown menu")
            let unpinTitle = NSLocalizedString("trackersViewController.collectionView.unpinTitle", comment: "Item in the dropdown menu")
            let editTitle = NSLocalizedString("trackersViewController.collectionView.editTitle", comment: "Item in the dropdown menu")
            let deleteTitle = NSLocalizedString("trackersViewController.collectionView.deleteTitle", comment: "Item in the dropdown menu")
            
            var menuActions: [UIMenuElement] = []
            
            if tracker.isPinned {
                menuActions.append(
                    UIAction(title: unpinTitle) { [weak self] _ in
                        self?.togglePinTracker(indexPath: indexPath)
                    })
            } else {
                menuActions.append(
                    UIAction(title: pinTitle) { [weak self] _ in
                        self?.togglePinTracker(indexPath: indexPath)
                    }
                )
            }
            menuActions.append(
                UIAction(title: editTitle) { [weak self] _ in
                    self?.editTracker(indexPath: indexPath)
                })
            menuActions.append(
                UIAction(title: deleteTitle, attributes: .destructive) { [weak self] _ in
                    self?.deleteTracker(indexPath: indexPath)
                })
            
            return UIMenu(children: menuActions)
        })
    }
    
    private func togglePinTracker(indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackerList[indexPath.row]
        
        try? self.trackerStore.togglePinTracker(withId: tracker.id)
        updateCategoriesFromCategoryStore()
        updateCollectionView()
    }
    
    private func editTracker(indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackerList[indexPath.row]
        guard let categoryTitle = try? trackerStore.getTrackerById(with: tracker.id).trackerCategory?.title else { return }
        let label = NSLocalizedString("trackersViewController.editTracker.label", comment: "Edit tracker label")
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell else { return }
        
        if let _ = tracker.schedule {
            let viewController = CreateEventTrackerViewController(delegate: self, id: tracker.id)
            viewController.didSelectCreateRegularEvent()
            viewController.setupViewControllerForEditing(
                label: label,
                textFieldText: tracker.name,
                categoryTitle: categoryTitle,
                schedule: tracker.schedule,
                emojii: tracker.emojii,
                color: tracker.color,
                trackerText: cell.getCounterText()
            )
            viewController.modalPresentationStyle = .formSheet
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        } else {
            let viewController = CreateEventTrackerViewController(delegate: self, id: tracker.id)
            viewController.setupViewControllerForEditing(
                label: label,
                textFieldText: tracker.name,
                categoryTitle: categoryTitle,
                schedule: nil,
                emojii: tracker.emojii,
                color: tracker.color,
                trackerText: cell.getCounterText()
            )
            viewController.modalPresentationStyle = .formSheet
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        }
    }
    
    private func deleteTracker(indexPath: IndexPath) {
        
        let tracker = visibleCategories[indexPath.section].trackerList[indexPath.row]
        let model = AlertModel(
            title: "Уверены что хотите удалить трекер?",
            message: nil,
            actions: [
                AlertActionModel(title: "Отменить", style: .cancel, handler: nil),
                AlertActionModel(title: "Удалить", style: .destructive, handler: { [weak self] _ in
                    try? self?.trackerStore.removeTracker(withId: tracker.id)
                    self?.updateCollectionView()
                }),
            ]
        )
        AlertPresenter.show(model: model, viewController: self, preferredStyle: .actionSheet)
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
        let newCell = visibleCategories[indexPath.section].trackerList[indexPath.row]
        
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
            let tracker = visibleCategories[indexPath.section].trackerList[indexPath.row]
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
        if collectionView.numberOfSections != visibleCategories.count {
            
            let newSectionIndex = visibleCategories.count - 1
            collectionView.insertSections(IndexSet(integer: newSectionIndex))
        }
    }
    
    func categoryStore(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categories = trackerCategoryStore.categories
        let dayOfWeekString = getDayOfWeekFromDate(date: currentDate)
        let oldFilteredTrackerListCount = visibleCategories.first?.trackerList.count ?? 0
        visibleCategories = filterCategories(for: dayOfWeekString)
        guard let filteredTrackerListCount = visibleCategories.first?.trackerList.count else { return }
        
        if filteredTrackerListCount > oldFilteredTrackerListCount {
            collectionView.reloadData()
        }
    }
}
