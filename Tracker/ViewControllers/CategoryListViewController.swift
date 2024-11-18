//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 09.08.2024.
//

import UIKit

protocol CategoryListViewControllerProtocol: AnyObject {
    var createEventTrackerViewController: CreateEventTrackerViewControllerProtocol? { get set }
    var addCategoryDelegate: AddCategoryViewControllerProtocol? { get set }
    func fetchCategories()
}

final class CategoryListViewController: UIViewController, CategoryListViewControllerProtocol {
    weak var createEventTrackerViewController: CreateEventTrackerViewControllerProtocol?
    weak var addCategoryDelegate: AddCategoryViewControllerProtocol?
    var categories: [TrackerCategory] = []
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Категория"
        return label
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
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        label.text = "Привычки и события можно\n объединить по смыслу"
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        
        tableView.allowsSelection = true
        tableView.register(BaseTableViewCell.self, forCellReuseIdentifier: "CategoryListCell")
        
        return tableView
    }()
    
    private let addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
        hideImageViewIfCategoryIsNotEmpty()
        createEventTrackerViewController?.loadLastSelectedCategory()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            titleLabel,
            tableView,
            imageView,
            imageViewLabel,
            addCategoryButton,
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
        addCategoryDelegate = viewController
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
    }
    
    private func hideImageViewIfCategoryIsNotEmpty() {
        if categories.isEmpty {
            imageView.isHidden = false
            imageViewLabel.isHidden = false
        } else {
            imageView.isHidden = true
            imageViewLabel.isHidden = true
        }
    }
}

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryListCell", for: indexPath)
        
        let categoryTitle = categories[indexPath.row].title
        
        cell.textLabel?.text = categoryTitle
        cell.accessoryType = (categoryTitle == createEventTrackerViewController?.selectedCategory) ? .checkmark : .none
        
        cell.backgroundColor = .ypBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCategory = categories[indexPath.row].title
        UserDefaults.standard.set(selectedCategory, forKey: "lastSelectedCategory")
        
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        cell.accessoryType = .checkmark
        
        createEventTrackerViewController?.didSelectCategory(selectedCategory)
        createEventTrackerViewController?.updateTableViewFirstCell()
        createEventTrackerViewController?.categoryDidChange()
        self.dismiss(animated: true)
    }
    
    @objc func fetchCategories() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
            tableView.reloadData()
            hideImageViewIfCategoryIsNotEmpty()
        } catch {
            print("Ошибка загрузки категорий: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? BaseTableViewCell else { return }
        cell.roundedCornersAndOffLastSeparatorVisibility(indexPath: indexPath, tableView: tableView)
    }
}
