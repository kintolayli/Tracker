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
    var selectedFilter: TrackerFilterItems { get set }
    func add(trackerCategory: TrackerCategory)
    func updateCollectionView()
    func  didSelectFilter(filter: TrackerFilterItems)
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
    var selectedFilter: TrackerFilterItems = TrackerFilterItems.allTrackers
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypMainBackground
        return collectionView
    }()
    
    private lazy var searchBar: UISearchTextField = {
        let searchBar = UISearchTextField()
        searchBar.placeholder = L10n.TrackersViewController.SearchBar.placeholder
        return searchBar
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = ImageAsset.Image.dizzy
        return view
    }()
    
    private lazy var imageViewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = L10n.TrackersViewController.ImageViewLabel.text1
        return label
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        let title = L10n.TrackersViewController.FilterButton.title
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.masksToBounds = false
        
        return button
    }()
    
    private var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
        
        return datePicker
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCollectionView()
        
        AnalyticsService.openScreen()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AnalyticsService.closeScreen()
    }
    
    private func pinnedCategoriesFromCategoryStore() {
        trackerCategoryStore.currentDate = currentDate
        categories = trackerCategoryStore.pinnedCategories
        updateCollectionView()
    }
    
    private func completedCategoriesFromCategoryStore() {
        trackerCategoryStore.currentDate = currentDate
        categories = trackerCategoryStore.completedCategories
        updateCollectionView()
    }
    
    private func notCompletedCategoriesFromCategoryStore() {
        trackerCategoryStore.currentDate = currentDate
        categories = trackerCategoryStore.notCompletedCategories
        updateCollectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        trackerCategoryStore.delegate = self
        pinnedCategoriesFromCategoryStore()
        trackerRecords = trackerRecordStore.records
    }
    
    private func setupUI() {
        view.backgroundColor = .ypMainBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        let addTrackerButton = UIButton(type: .custom)
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let plusImage = UIImage(systemName: "plus", withConfiguration: configuration)
        addTrackerButton.setImage(plusImage, for: .normal)
        addTrackerButton.tintColor = .ypBlack
        addTrackerButton.addTarget(self, action: #selector(didTapTrackerButton), for: .touchUpInside)
        addTrackerButton.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        buttonView.bounds = buttonView.bounds.offsetBy(dx: 10, dy: 0)
        buttonView.addSubview(addTrackerButton)
        let addButton = UIBarButtonItem(customView: buttonView)
        navigationItem.leftBarButtonItem = addButton
        
        navigationItem.title = L10n.TrackersViewController.NavigationItem.title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            searchBar,
            collectionView,
            imageView,
            imageViewLabel,
            filterButton
        ])
        
        view.bringSubviewToFront(filterButton)
        
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
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 75, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        
        searchBar.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        filterButton.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        enableKeyboardDismissOnTap()
    }
    
    @objc private func filterButtonDidTap() {
        let viewController = TrackersFilterViewController(trackersViewController: self)
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
        
        AnalyticsService.clickFilter()
    }
    
    func didSelectFilter(filter: TrackerFilterItems) {
        switch filter {
        case .allTrackers:
            print(".allTrackers")
            selectedFilter = TrackerFilterItems.allTrackers
            pinnedCategoriesFromCategoryStore()
            filterButton.titleLabel?.textColor = .ypWhite
        case .todayTrackers:
            print(".todayTrackers")
            pinnedCategoriesFromCategoryStore()
            datePicker.date = Date()
            filterButton.titleLabel?.textColor = .ypColorSelection1
            updateEmptyStateViewVisibilityAfterSearch()
        case .completed:
            print(".completed")
            completedCategoriesFromCategoryStore()
            filterButton.titleLabel?.textColor = .ypColorSelection1
            updateEmptyStateViewVisibilityAfterSearch()
        case .notCompleted:
            print(".notCompleted")
            notCompletedCategoriesFromCategoryStore()
            filterButton.titleLabel?.textColor = .ypColorSelection1
            updateEmptyStateViewVisibilityAfterSearch()
        }
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
        updateEmptyStateViewVisibilityAfterSearch()
    }
    
    private func updateEmptyStateViewVisibility() {
        let nonEmptyCategories = visibleCategories.filter { !$0.trackerList.isEmpty }
        let isTrackerListEmpty = nonEmptyCategories.isEmpty
        
        let image = ImageAsset.Image.dizzy
        let text = L10n.TrackersViewController.ImageViewLabel.text1
        
        imageView.isHidden = !isTrackerListEmpty
        imageView.image = image
        imageViewLabel.isHidden = !isTrackerListEmpty
        imageViewLabel.text = text
    }
    
    private func updateEmptyStateViewVisibilityAfterSearch() {
        let nonEmptyCategories = filteredCategories.filter { !$0.trackerList.isEmpty }
        let isTrackerListEmpty = nonEmptyCategories.isEmpty
        
        let image = ImageAsset.Image._2
        let text = L10n.TrackersViewController.ImageViewLabel.text2
        
        imageView.isHidden = !isTrackerListEmpty
        imageView.image = image
        imageViewLabel.isHidden = !isTrackerListEmpty
        imageViewLabel.text = text
    }
    
    @objc private func didTapTrackerButton() {
        let viewController = ChooseTypeTrackerViewController()
        viewController.trackersViewController = self
        chooseTypeTrackerDelegate = viewController
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
        
        AnalyticsService.didTapAddTrackerButton()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        if selectedFilter != .todayTrackers {
            updateCollectionView()
        } else {
            didSelectFilter(filter: .allTrackers)
        }
    }
    
    func add(trackerCategory: TrackerCategory) {
        try? trackerCategoryStore.updateTrackerCategory(trackerCategory)
        pinnedCategoriesFromCategoryStore()
        didSelectFilter(filter: selectedFilter)
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
                    guard let recordsFromCurrentCell = try? trackerRecordStore.getTrackerRecords(with: tracker.id) else { return [] }
                    
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
        
        cell.layer.cornerRadius = 16
        
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
            
            let pinTitle = L10n.TrackersViewController.CollectionView.pinTitle
            let unpinTitle = L10n.TrackersViewController.CollectionView.unpinTitle
            let editTitle = L10n.TrackersViewController.CollectionView.editTitle
            let deleteTitle = L10n.TrackersViewController.CollectionView.deleteTitle
            
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
        pinnedCategoriesFromCategoryStore()
        updateCollectionView()
    }
    
    private func editTracker(indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackerList[indexPath.row]
        guard let categoryTitle = try? trackerStore.getTrackerById(with: tracker.id).trackerCategory?.title else { return }
        let label = L10n.TrackersViewController.EditTracker.label
        
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
        
        AnalyticsService.selectContextMenuEdit()
    }
    
    private func deleteTracker(indexPath: IndexPath) {
        
        let tracker = visibleCategories[indexPath.section].trackerList[indexPath.row]
        
        let title = L10n.TrackersViewController.DeleteTracker.title
        let cancel = L10n.TrackersViewController.DeleteTracker.cancel
        let delete = L10n.TrackersViewController.DeleteTracker.delete
        
        let model = AlertModel(
            title: title,
            message: nil,
            actions: [
                AlertActionModel(title: cancel, style: .cancel, handler: nil),
                AlertActionModel(title: delete, style: .destructive, handler: { [weak self] _ in
                    self?.trackerRecordStore.removeAllTrackerRecord(with: tracker.id)
                    try? self?.trackerStore.removeTracker(withId: tracker.id)
                    self?.didSelectFilter(filter: self?.selectedFilter ?? .allTrackers)
                }),
            ]
        )
        AlertPresenter.show(model: model, viewController: self, preferredStyle: .actionSheet)
        
        AnalyticsService.selectContextMenuDelete()
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
        
        if let recordsFromCurrentCell = try? trackerRecordStore.getTrackerRecords(with: newCell.id) {
            cellCount = recordsFromCurrentCell.count
            
            if (checkExistsRecord(in: recordsFromCurrentCell, with: currentDate) != nil) {
                cellState = true
            }
        }
        
        return (cellCount, cellState)
    }
    
    private func checkExistsRecord(in records: [TrackerRecord], with date: Date) -> TrackerRecord? {
        var resultRecord: TrackerRecord?
        
        for record in records {
            if isSameDay(date1: record.date, date2: date) {
                resultRecord = record
            }
        }
        return resultRecord
    }
    
    func trackersViewControllerCellTap(_ cell: TrackersCollectionViewCell) {
        if currentDate <= Date() {
            guard let indexPath = collectionView.indexPath(for: cell)  else { return }
            let tracker = visibleCategories[indexPath.section].trackerList[indexPath.row]
            guard let recordsFromCurrentCell = try? trackerRecordStore.getTrackerRecords(with: tracker.id) else { return }
            
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
                title: L10n.TrackersViewController.TrackersViewControllerCellTap.AlertModel.title,
                message: L10n.TrackersViewController.TrackersViewControllerCellTap.AlertModel.message,
                buttonTitle: L10n.TrackersViewController.TrackersViewControllerCellTap.AlertModel.buttonTitle,
                buttonAction: nil
            )
            AlertPresenter.show(model: alertModel, viewController: self)
        }
        
        AnalyticsService.clickTracker()
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
