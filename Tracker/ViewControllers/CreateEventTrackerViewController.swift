//
//  CreateRegularEventTrackerViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 08.08.2024.
//

import UIKit


protocol CreateEventTrackerViewControllerProtocol: AnyObject {
    var chooseTypeTrackerViewController: ChooseTypeTrackerViewControllerProtocol? { get set }
    var trackerViewControllerEditDelegate: TrackersViewControllerProtocol? { get set }
    var sheduleDelegate: SheduleViewControllerProtocol? { get set }
    var selectedCategory: String? { get set }
    func categoryDidChange()
    func didSelectCategory(_ category: String)
    func loadLastSelectedCategory()
    func didSelectDays(_ daysString: String)
    func updateTableViewFirstCell()
    func updateTableViewSecondCell()
}


final class CreateEventTrackerViewController: UIViewController, CreateEventTrackerViewControllerProtocol {
    
    var trackerViewControllerEditDelegate: TrackersViewControllerProtocol?
    
    weak var chooseTypeTrackerViewController: ChooseTypeTrackerViewControllerProtocol?
    var sheduleDelegate: SheduleViewControllerProtocol?
    
    var selectedCategory: String?
    private var schedule: [Day]?
    private let emojies = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪",]
    private let colors: [UIColor] = [
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
    private var selectedEmojii: String?
    private var selectedColor: UIColor?
    private var trackerId: UUID
    
    init(delegate: TrackersViewControllerProtocol, id: UUID) {
        self.trackerViewControllerEditDelegate = delegate
        self.trackerId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        self.trackerId = UUID()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let suplementaryViewHeaderList = [
        L10n.CreateEventTrackerViewController.SuplementaryViewHeaderList.item1,
        L10n.CreateEventTrackerViewController.SuplementaryViewHeaderList.item2
    ]
    
    private var menuItems: [String] = [
        L10n.CreateEventTrackerViewController.MenuItems.item1
    ]
    private var menuSecondaryItems: [[String]] = [[""], [""]]
    
    private var isCreateRegularEventTracker: Bool = false
    private let params: GeometricParams = {
        let params = GeometricParams(cellCount: 6, leftInset: 16, rightInset: 16, cellSpacing: 6)
        return params
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = L10n.CreateEventTrackerViewController.IrregularEventTracker.TitleLabel.text
        return label
    }()
    
    private lazy var dayCounterLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.isHidden = true
        
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = L10n.CreateEventTrackerViewController.TextField.placeholder
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.textAlignment = .left
        textField.maxLength = 38
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        clearButton.tintColor = .ypGray
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        rightPaddingView.addSubview(clearButton)
        clearButton.frame = CGRect(x: 0, y: 6, width: 16, height: 16)
        
        textField.rightView = rightPaddingView
        textField.rightViewMode = .never
        
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.allowsSelection = true
        tableView.register(BaseTableViewCell.self, forCellReuseIdentifier: "RegularEventTrackerCell")
        tableView.separatorColor = .ypGray
        tableView.backgroundColor = .ypBackground
        
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        let title =  L10n.CreateEventTrackerViewController.CancelButton.title
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        let title = L10n.CreateEventTrackerViewController.CreateButton.title
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLastSelectedCategory()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypMainBackground
        
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            scrollView
        ])
        
        scrollView.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([contentView])
        
        contentView.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            titleLabel,
            dayCounterLabel,
            textField,
            tableView,
            collectionView,
            cancelButton,
            createButton
        ])
        
        if dayCounterLabel.isHidden {
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38).isActive = true
        } else {
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38 * 3).isActive = true
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 820 + CGFloat(menuItems.count * 75)),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            dayCounterLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            dayCounterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(menuItems.count * 75)),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            cancelButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 172),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            
            createButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 172),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonDidTap), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmojiesColorCollectionViewCell.self, forCellWithReuseIdentifier: "EmojiesColorCollectionViewCell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(categoryDidChange), name: .categoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleDidChange), name: .scheduleDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(emojiiDidChange), name: .emojiiDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorDidChange), name: .colorDidChange, object: nil)
        
        enableKeyboardDismissOnTap()
    }
    
    func loadLastSelectedCategory() {
        if let lastSelectedCategory = UserDefaults.standard.string(forKey: "lastSelectedCategory") {
            selectedCategory = lastSelectedCategory
            menuSecondaryItems[0][0] = lastSelectedCategory
            updateTableViewFirstCell()
        }
    }
    
    private func loadCategoryWhenEditing(category: String) {
        selectedCategory = category
        menuSecondaryItems[0][0] = category
        updateTableViewFirstCell()
        
        let viewController = CategoryListViewController()
        guard let category = selectedCategory else { return }
        viewController.viewModel.saveLastSelectedCategory(selectedCategoryTitle: category)
    }
    
    private func loadSchedule(schedule: [Day]) {
        let sheduleViewController = SheduleViewController()
        sheduleDelegate = sheduleViewController
        guard let textSchedule = sheduleDelegate?.shortStringFromSelectedDays(days: schedule) else { return }
        didSelectDays(textSchedule)
        sheduleViewController.createEventTrackerViewController = self
        sheduleViewController.updateDays(from: menuSecondaryItems[1][0])
    }
    
    private func selectEmojii() {
        guard let emojii = selectedEmojii else { return }
        guard let index = emojies.firstIndex(of: emojii) else { return }
        
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    private func selectColor() {
        guard let color = selectedColor else { return }
        guard let index = colors.firstIndex(of: color) else { return }
        
        let indexPath = IndexPath(item: index, section: 1)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    private func createButtonTitleChange() {
        let title = L10n.CreateEventTrackerViewController.CreateButton.titleWhenEdit
        createButton.setTitle(title, for: .normal)
    }
    
    func setupViewControllerForEditing(
        label: String,
        textFieldText: String,
        categoryTitle: String,
        schedule: [Day]?,
        emojii: String,
        color: UIColor,
        trackerText: String
    ) {
        dayCounterLabel.isHidden = false
        dayCounterLabel.text = trackerText
        selectedEmojii = emojii
        selectedColor = color
        titleLabel.text = label
        textField.text = textFieldText
        loadCategoryWhenEditing(category: categoryTitle)
        if let newSchedule = schedule {
            loadSchedule(schedule: newSchedule as [Day])
        }
        createButtonTitleChange()
    }
    
    func didSelectCreateRegularEvent() {
        menuItems.append(L10n.CreateEventTrackerViewController.MenuItems.item2)
        titleLabel.text = L10n.CreateEventTrackerViewController.RegularEventTracker.TitleLabel.text
        isCreateRegularEventTracker = true
    }
    
    func updateTableViewFirstCell() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let secondaryText = menuSecondaryItems[indexPath.row][0]
        
        if #available(iOS 14.0, *) {
            var content = UIListContentConfiguration.cell()
            content.secondaryText = secondaryText
            content.secondaryTextProperties.font = .systemFont(ofSize: 17, weight: .regular)
            content.secondaryTextProperties.color = .ypGray
            cell.contentConfiguration = content
        } else {
            cell.detailTextLabel?.text = secondaryText
            cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.detailTextLabel?.textColor = .ypGray
        }
        
        tableView.performBatchUpdates {
            let indexPaths = [indexPath]
            tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    func updateTableViewSecondCell() {
        let indexPath = IndexPath(row: 1, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let secondaryText = menuSecondaryItems[indexPath.row][0]
        
        if #available(iOS 14.0, *) {
            var content = UIListContentConfiguration.cell()
            content.secondaryText = secondaryText
            content.secondaryTextProperties.font = .systemFont(ofSize: 17, weight: .regular)
            content.secondaryTextProperties.color = .ypGray
            cell.contentConfiguration = content
        } else {
            cell.detailTextLabel?.text = secondaryText
            cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.detailTextLabel?.textColor = .ypGray
        }
        
        tableView.performBatchUpdates {
            let indexPaths = [indexPath]
            tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    func didSelectCategory(_ category: String) {
        menuSecondaryItems[0][0] = category
        selectedCategory = category
    }
    
    func didSelectDays(_ daysString: String) {
        menuSecondaryItems[1][0] = daysString
    }
    
    private func updateCreateButtonState() {
        let isCategoryEmpty = menuSecondaryItems[0][0] == ""
        let isSheduleEmpty = menuSecondaryItems[1][0] == ""
        guard let isTextFieldEmpty = textField.text?.isEmpty else { return }
        let isEmojiiNotNil = (selectedEmojii != nil)
        let isColorNotNil = (selectedColor != nil)
        
        if isCreateRegularEventTracker {
            createButton.isEnabled = !isTextFieldEmpty && !isCategoryEmpty && !isSheduleEmpty && isEmojiiNotNil && isColorNotNil
        } else {
            createButton.isEnabled = !isTextFieldEmpty && !isCategoryEmpty && isEmojiiNotNil && isColorNotNil
        }
        
        if traitCollection.userInterfaceStyle == .dark {
            if createButton.isEnabled {
                createButton.setTitleColor(.ypAlwaysBlack, for: .normal)
            } else {
                createButton.setTitleColor(.ypWhite, for: .normal)
            }
        }
        
        createButton.backgroundColor = createButton.isEnabled ? .ypBlack : .ypGray
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            textField.rightViewMode = .always
        } else {
            textField.rightViewMode = .never
        }
        
        updateCreateButtonState()
    }
    
    @objc private func clearText() {
        textField.text = ""
        textField.sendActions(for: .editingChanged)
    }
    
    @objc func categoryDidChange() {
        updateCreateButtonState()
    }
    
    @objc
    func scheduleDidChange() {
        updateCreateButtonState()
    }
    
    @objc
    private func emojiiDidChange() {
        updateCreateButtonState()
    }
    
    @objc
    private func colorDidChange() {
        updateCreateButtonState()
    }
    
    @objc
    private func cancelButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    @objc
    private func createButtonDidTap() {
        
        guard let name = textField.text else { return }
        guard let category = selectedCategory else { return }
        if isCreateRegularEventTracker {
            schedule = sheduleDelegate?.getShedule()
        }
        guard let emojii = selectedEmojii else { return }
        guard let color = selectedColor else { return }
        
        let newTracker = Tracker(id: trackerId, name: name, color: color, emojii: emojii, schedule: schedule, isPinned: false)
        let newTrackerCategory = TrackerCategory(title: category, trackerList: [newTracker])
        
        if let editDelegate = trackerViewControllerEditDelegate {
            editDelegate.add(trackerCategory: newTrackerCategory)
            editDelegate.updateCollectionView()
            self.dismiss(animated: true)
        } else {
            chooseTypeTrackerViewController?.trackersViewController?.add(trackerCategory: newTrackerCategory)
            chooseTypeTrackerViewController?.trackersViewController?.updateCollectionView()
            self.dismiss(animated: true)
            self.chooseTypeTrackerViewController?.dismiss(animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CreateEventTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegularEventTrackerCell", for: indexPath)
        
        cell.prepareForReuse()
        cell.accessoryType = .disclosureIndicator
        
        let text = menuItems[indexPath.row]
        
        if let lastSelectedCategory = selectedCategory {
            menuSecondaryItems[0][0] = lastSelectedCategory
        }
        
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
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let viewController = CategoryListViewController()
            if let category = selectedCategory {
                viewController.viewModel.saveLastSelectedCategory(selectedCategoryTitle: category)
            }
            viewController.createEventTrackerViewController = self
            viewController.modalPresentationStyle = .formSheet
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        } else {
            let viewController = SheduleViewController()
            viewController.createEventTrackerViewController = self
            viewController.updateDays(from: menuSecondaryItems[1][0])
            sheduleDelegate = viewController
            viewController.modalPresentationStyle = .formSheet
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? BaseTableViewCell else { return }
        cell.roundedCornersAndOffLastSeparatorVisibility(indexPath: indexPath, tableView: tableView)
    }
}

extension CreateEventTrackerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiesColorCollectionViewCell", for: indexPath) as? EmojiesColorCollectionViewCell else { return UICollectionViewCell() }
        cell.prepareForReuse()
        
        if indexPath.section == 0 {
            let emojii = emojies[indexPath.row]
            cell.updateCell(backgroundColor: .clear, emojiiLabelText: emojii)
            
            if let _ = trackerViewControllerEditDelegate {
                let selectEmojii = selectedEmojii ?? "🙂"
                let index = emojies.firstIndex(of: selectEmojii) ?? 0
                let indexPath = IndexPath(item: index, section: 0)
                
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
                collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
            }
        } else {
            let color = colors[indexPath.row]
            cell.updateCell(backgroundColor: color)
            
            if let _ = trackerViewControllerEditDelegate {
                let selectColor = selectedColor ?? colors[0]
                let index = colors.firstIndex(where: { $0.isEqualToColor(selectColor) }) ?? 0
                let indexPath = IndexPath(item: index, section: 1)
                
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
                collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
            }
        }
        
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
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView
        
        guard let view else { return UICollectionReusableView() }
        view.updateLabel(text: suplementaryViewHeaderList[indexPath.section])
        
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return suplementaryViewHeaderList.count
    }
    
    private func clearSelectionFromCells(in section: Int) {
        for cell in collectionView.visibleCells {
            if let cell = cell as? EmojiesColorCollectionViewCell, let indexPath = collectionView.indexPath(for: cell), indexPath.section == section {
                if section == 0 {
                    cell.updateCell(isHideEmojiiLabelSelectionView: true)
                } else if section == 1 {
                    cell.updateCell(isHideColorViewSelection: true)
                }
            }
        }
    }
    
    private func selectCell(in indexPath: IndexPath, selectedCell: EmojiesColorCollectionViewCell) {
        if indexPath.section == 0 {
            selectedCell.updateCell(isHideEmojiiLabelSelectionView: false)
            selectedEmojii = emojies[indexPath.row]
            emojiiDidChange()
        } else if indexPath.section == 1 {
            selectedCell.updateCell(isHideColorViewSelection: false)
            selectedColor = colors[indexPath.row]
            colorDidChange()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiesColorCollectionViewCell else { return }
        
        clearSelectionFromCells(in: indexPath.section)
        selectCell(in: indexPath, selectedCell: cell)
    }
}

extension CreateEventTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: params.leftInset, bottom: 40, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}
