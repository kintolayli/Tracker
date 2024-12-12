//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 09.08.2024.
//

import UIKit

protocol CategoryListViewControllerProtocol: AnyObject {
    var createEventTrackerViewController: CreateEventTrackerViewControllerProtocol? { get set }
    var viewModel: CategoryListViewModelProtocol { get }
}

protocol CategoryListViewModelProtocol {
    var categories: [TrackerCategory] { get set }
    var didFetchCategories: Binding<[TrackerCategory]>? { get set }
    var didSelectCategoryHandler: Binding<String>? { get set }
    var trackerCategoryStore: TrackerCategoryStore { get }
    var trackerRecordStore: TrackerRecordStore { get }
    var trackerStore: TrackerStore { get }
    func fetchCategories()
    func didSelectCategory(_ categoryTitle: String)
    func saveLastSelectedCategory(selectedCategoryTitle: String)
    func deleteLastSelectedCategory(selectedCategoryTitle: String)
    func saveCategory(text: String, oldCategoryName: String?)
}

final class CategoryListViewController: UIViewController, CategoryListViewControllerProtocol {
    weak var createEventTrackerViewController: CreateEventTrackerViewControllerProtocol?

    lazy var viewModel: CategoryListViewModelProtocol = {
        lazy var trackerRecordStore: TrackerRecordStore = {
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                assertionFailure(TrackersViewControllerError.loadContextError.localizedDescription)

                let fallbackContext = DefaultContext(concurrencyType: .mainQueueConcurrencyType)
                return TrackerRecordStore(context: fallbackContext)
            }
            return TrackerRecordStore(context: context)
        }()

        lazy var trackerStore: TrackerStore = {
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                assertionFailure(TrackersViewControllerError.loadContextError.localizedDescription)

                let fallbackContext = DefaultContext(concurrencyType: .mainQueueConcurrencyType)
                return TrackerStore(context: fallbackContext)
            }
            return TrackerStore(context: context)
        }()

        lazy var trackerCategoryStore: TrackerCategoryStore = {
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                assertionFailure(TrackersViewControllerError.loadContextError.localizedDescription)

                let fallbackContext = DefaultContext(concurrencyType: .mainQueueConcurrencyType)
                return TrackerCategoryStore(context: fallbackContext)
            }
            return TrackerCategoryStore(context: context)
        }()

        let viewModel = CategoryListViewModel(
            trackerCategoryStore: trackerCategoryStore,
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore
        )
        return viewModel
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = L10n.CategoryListViewController.TitleLabel.text
        return label
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
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        label.text = L10n.CategoryListViewController.ImageViewLabel.text
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true

        tableView.allowsSelection = true
        tableView.register(BaseTableViewCell.self, forCellReuseIdentifier: "CategoryListCell")
        tableView.separatorColor = .ypGray

        return tableView
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        let title = L10n.CategoryListViewController.AddCategoryButton.title
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypMainBackground, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchCategories()
        hideImageViewIfCategoryIsNotEmpty()
        createEventTrackerViewController?.loadLastSelectedCategory()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
    }

    private func setupBindings() {
        viewModel.didFetchCategories = { [weak self] categories in
            self?.viewModel.categories = categories
            self?.tableView.reloadData()
            self?.createEventTrackerViewController?.chooseTypeTrackerViewController?.trackersViewController?.updateCollectionView()
            self?.hideImageViewIfCategoryIsNotEmpty()
        }

        viewModel.didSelectCategoryHandler = { [weak self] categoryTitle in
            self?.createEventTrackerViewController?.viewModel.didSelectCategory(categoryTitle)
            self?.createEventTrackerViewController?.updateTableViewFirstCell()
            self?.createEventTrackerViewController?.categoryDidChange()
            self?.dismiss(animated: true)
        }
    }

    private func setupUI() {
        view.backgroundColor = .ypMainBackground
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            titleLabel,
            tableView,
            imageView,
            imageViewLabel,
            addCategoryButton
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            imageViewLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            imageViewLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 550),

            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonDidTap), for: .touchUpInside)

        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc private func addCategoryButtonDidTap() {
        let viewController = AddCategoryViewController()
        viewController.categoryListViewController = self
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
    }

    private func hideImageViewIfCategoryIsNotEmpty() {
        let isEmpty = viewModel.categories.isEmpty
        imageView.isHidden = !isEmpty
        imageViewLabel.isHidden = !isEmpty
    }

    private func editCategory(indexPath: IndexPath) {
        let categoryTitle = viewModel.categories[indexPath.row].title

        let viewController = AddCategoryViewController()
        viewController.setupViewControllerForEditing(text: categoryTitle)
        viewController.categoryListViewController = self
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
    }

    private func deleteCategory(indexPath: IndexPath) {
        let categoryTitle = viewModel.categories[indexPath.row].title

        let title = L10n.CategoryListViewController.DeleteCategory.title
        let cancel = L10n.CategoryListViewController.DeleteCategory.cancel
        let delete = L10n.CategoryListViewController.DeleteCategory.delete

        let model = AlertModel(
            title: title,
            message: nil,
            actions: [
                AlertActionModel(title: cancel, style: .cancel, handler: nil),
                AlertActionModel(title: delete, style: .destructive, handler: { [weak self] _ in
                    guard let trackers = try? self?.viewModel.trackerStore.fetchAllTrackersWithCategory(categoryTitle: categoryTitle) else { return }

                    for tracker in trackers {
                        self?.viewModel.trackerRecordStore.removeAllTrackerRecord(with: tracker.id)
                        try? self?.viewModel.trackerStore.removeTracker(withId: tracker.id)
                    }
                    try? self?.viewModel.trackerCategoryStore.deleteCategory(with: categoryTitle)
                    self?.viewModel.deleteLastSelectedCategory(selectedCategoryTitle: categoryTitle)
                    self?.viewModel.fetchCategories()

                    // Обновляем collectionView - в зависимости от того как мы зашли в удаление категорий - через создание нового трекера или через редактирование, ссылка на trackersViewController будет разной
                    if let editDelegate = self?.createEventTrackerViewController?.trackerViewControllerEditDelegate {
                        editDelegate.updateCollectionView()
                    } else {
                        self?.createEventTrackerViewController?.chooseTypeTrackerViewController?.trackersViewController?.updateCollectionView()
                    }

                    self?.createEventTrackerViewController?.viewModel.selectedCategory = ""
                    self?.createEventTrackerViewController?.loadLastSelectedCategory()
                    self?.createEventTrackerViewController?.updateTableViewFirstCell()
                    self?.createEventTrackerViewController?.categoryDidChange()
                })
            ]
        )
        AlertPresenter.show(model: model, viewController: self, preferredStyle: .actionSheet)
    }
}

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryListCell", for: indexPath)
        let categoryTitle = viewModel.categories[indexPath.row].title

        cell.textLabel?.text = categoryTitle
        cell.accessoryType = (categoryTitle == createEventTrackerViewController?.viewModel.selectedCategory) ? .checkmark : .none
        cell.backgroundColor = .ypBackground

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = viewModel.categories[indexPath.row].title
        viewModel.saveLastSelectedCategory(selectedCategoryTitle: selectedCategory)

        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        cell.accessoryType = .checkmark

        viewModel.didSelectCategory(selectedCategory)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? BaseTableViewCell else { return }
        cell.roundedCornersAndOffLastSeparatorVisibility(indexPath: indexPath, tableView: tableView)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(actionProvider: { actions in
            let editTitle = L10n.TrackersViewController.CollectionView.editTitle
            let deleteTitle = L10n.TrackersViewController.CollectionView.deleteTitle
            var menuActions: [UIMenuElement] = []

            menuActions.append(
                UIAction(title: editTitle) { [weak self] _ in
                    self?.editCategory(indexPath: indexPath)
                })
            menuActions.append(
                UIAction(title: deleteTitle, attributes: .destructive) { [weak self] _ in
                    self?.deleteCategory(indexPath: indexPath)
                })

            return UIMenu(children: menuActions)
        })
    }
}
