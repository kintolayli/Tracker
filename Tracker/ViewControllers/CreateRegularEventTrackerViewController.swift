//
//  CreateRegularEventTrackerViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 08.08.2024.
//

import UIKit


protocol SheduleEventTrackerViewControllerProtocol: BaseEventTrackerViewControllerProtocol {
    var sheduleDelegate: SheduleViewControllerProtocol? { get set }
    func didSelectDays(_ daysString: String)
    func updateTableViewSecondCell()
}


final class CreateRegularEventTrackerViewController: UIViewController, SheduleEventTrackerViewControllerProtocol {
    
    weak var chooseTypeTrackerViewController: ChooseTypeTrackerViewControllerProtocol?
    weak var categoryListDelegate: CategoryListViewControllerProtocol?
    var sheduleDelegate: SheduleViewControllerProtocol?
    
    private let emojies = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥",]
    private var selectedEmojii: String?
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
    private var selectedColor: UIColor?
    private let suplementaryViewHeaderList = ["Emojii", "Цвет"]
    private let menuItems: [String] = ["Категория", "Расписание"]
    var menuSecondaryItems: [[String]] = [[""], [""]]
    private let params: GeometricParams = {
        let params = GeometricParams(cellCount: 6, leftInset: 16, rightInset: 16, cellSpacing: 6)
        return params
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Новая привычка"
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
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
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.allowsSelection = true
        tableView.register(BaseTableViewCell.self, forCellReuseIdentifier: "RegularEventTrackerCell")
        
        return tableView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let menuSecondaryItemFirst = chooseTypeTrackerViewController?.trackersViewController?.categories.first else { return }
        menuSecondaryItems[0] = [menuSecondaryItemFirst.title]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            scrollView
        ])
        
        scrollView.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([contentView])
        
        contentView.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            titleLabel,
            textField,
            tableView,
            collectionView,
            cancelButton,
            createButton
        ])
        
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
            contentView.heightAnchor.constraint(equalToConstant: 970),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 87),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalToConstant: 460),
            
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
        menuSecondaryItems[0] = [category]
        chooseTypeTrackerViewController?.trackersViewController?.lastSelectedCategory = category
    }
    
    func didSelectDays(_ daysString: String) {
        menuSecondaryItems[1][0] = daysString
    }
    
    func updateCreateButtonState() {
        let isCategoryEmpty = menuSecondaryItems[0][0] == ""
        let isSheduleEmpty = menuSecondaryItems[1][0] == ""
        guard let isTextFieldEmpty = textField.text?.isEmpty else { return }
        let isEmojiiNotNil = (selectedEmojii != nil)
        let isColorNotNil = (selectedColor != nil)
        
        createButton.isEnabled = !isTextFieldEmpty && !isCategoryEmpty && !isSheduleEmpty && isEmojiiNotNil && isColorNotNil
        createButton.backgroundColor = createButton.isEnabled ? .ypBlack : .ypGray
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
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
    
    @objc func scheduleDidChange() {
        updateCreateButtonState()
    }
    
    @objc func emojiiDidChange() {
        updateCreateButtonState()
    }
    
    @objc func colorDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonDidTap() {
        
        guard let name = textField.text else { return }
        guard let color = selectedColor else { return }
        guard let emojii = selectedEmojii else { return }
        
        guard let shedule = sheduleDelegate?.getShedule() else { return }
        let newTracker = Tracker(name: name, color: color, emojii: emojii, schedule: shedule)
        guard let category = chooseTypeTrackerViewController?.trackersViewController?.lastSelectedCategory else { return }
        
        let newTrackerCategory = TrackerCategory(title: category, trackerList: [newTracker])
        
        self.chooseTypeTrackerViewController?.trackersViewController?.add(trackerCategory: newTrackerCategory)
        self.dismiss(animated: true)
        self.chooseTypeTrackerViewController?.dismiss(animated: true)
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
        cell.accessoryType = .disclosureIndicator
        
        let text = menuItems[indexPath.row]
        
        if let lastSelectedCategory = chooseTypeTrackerViewController?.trackersViewController?.lastSelectedCategory {
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
            viewController.createEventTrackerViewController = self
            
            if let category = self.chooseTypeTrackerViewController?.trackersViewController?.lastSelectedCategory {
                viewController.selectedCategory = category
            }
            categoryListDelegate = viewController
            viewController.modalPresentationStyle = .formSheet
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        } else {
            let viewController = SheduleViewController()
            viewController.createRegularEventTrackerViewController = self
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


extension CreateRegularEventTrackerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiesColorCollectionViewCell", for: indexPath) as? EmojiesColorCollectionViewCell else { return UICollectionViewCell() }
        cell.prepareForReuse()
        
        if indexPath.section == 0 {
            let emojii = emojies[indexPath.row]
            cell.updateCell(backgroundColor: .clear, emojiiLabelText: emojii)
        } else {
            let color = colors[indexPath.row]
            cell.updateCell(backgroundColor: color)
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
        view.titleLabel.text = suplementaryViewHeaderList[indexPath.section]
        
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return suplementaryViewHeaderList.count
    }
    
    func clearSelectionFromCells(in section: Int) {
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
    
    func selectCell(in indexPath: IndexPath, selectedCell: EmojiesColorCollectionViewCell) {
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

extension CreateRegularEventTrackerViewController: UICollectionViewDelegateFlowLayout {
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
