//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 04.08.2024.
//

import UIKit

protocol StatisticsViewModelProtocol {
    var data: [(String, Int)] { get set }
    func isEmptyStatistics() -> Bool
    var onDataUpdated: (() -> Void)? { get set }
    func getItem(at index: Int) -> (String, Int)?
}

final class StatisticsViewController: UIViewController, StatisticsViewControllerDelegate {
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var viewModel: StatisticsViewModelProtocol

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.masksToBounds = true

        tableView.allowsSelection = true
        tableView.register(StatisticsTableViewCell.self, forCellReuseIdentifier: StatisticsTableViewCell.reuseIdentifier)
        tableView.separatorColor = .ypGray
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = false
        tableView.backgroundColor = .ypMainBackground

        return tableView
    }()

    private lazy var imageViewEmptyState: UIImageView = {
        let view = UIImageView()
        view.image = ImageAsset.Image._3
        return view
    }()

    private lazy var imageViewLabelEmptyState: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = L10n.StatisticsViewController.ImageViewLabel.text
        return label
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateTableView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.updateTableView()
        }
    }

    private func setupUI() {
        view.backgroundColor = .ypMainBackground
        navigationItem.title = L10n.StatisticsViewController.NavigationItem.title
        navigationController?.navigationBar.prefersLargeTitles = true

        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            imageViewEmptyState,
            imageViewLabelEmptyState,
            tableView
        ])

        NSLayoutConstraint.activate([
            imageViewEmptyState.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageViewEmptyState.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            imageViewLabelEmptyState.topAnchor.constraint(equalTo: imageViewEmptyState.bottomAnchor, constant: 8),
            imageViewLabelEmptyState.centerXAnchor.constraint(equalTo: imageViewEmptyState.centerXAnchor),

            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
    }

    private func updateEmptyStateViewVisibility() {
        let isStatisticsNotEmpty = viewModel.isEmptyStatistics()

        imageViewEmptyState.isHidden = !isStatisticsNotEmpty
        imageViewLabelEmptyState.isHidden = !isStatisticsNotEmpty
        tableView.isHidden = isStatisticsNotEmpty
    }

    private func updateTableView() {
        tableView.reloadData()
        updateEmptyStateViewVisibility()
    }
}


extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.reuseIdentifier, for: indexPath) as? StatisticsTableViewCell else { return UITableViewCell() }

        cell.delegate = self

        if let item = viewModel.getItem(at: indexPath.row) {
            cell.configure(with: item)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
