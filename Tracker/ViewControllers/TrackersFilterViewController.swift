//
//  TrackersFilterViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 28.11.2024.
//

import UIKit


class TrackersFilterViewController: UIViewController {
    weak var trackersViewController: (TrackersViewControllerProtocol)?

    init(trackersViewController: TrackersViewControllerProtocol) {
        self.trackersViewController = trackersViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let filterItems = TrackerFilterItems.allCases

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = L10n.TrackersViewController.FilterButton.title
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .ypMainBackground
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            titleLabel,
            tableView,
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 550)
        ])

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension TrackersFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryListCell", for: indexPath)
        let categoryTitle = filterItems[indexPath.row]

        cell.textLabel?.text = categoryTitle.filterName
        cell.accessoryType = (categoryTitle == trackersViewController?.selectedFilter) ? .checkmark : .none
        cell.backgroundColor = .ypBackground

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filterItems[indexPath.row]
        trackersViewController?.selectedFilter = selectedFilter

        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        cell.accessoryType = .checkmark

        trackersViewController?.didSelectFilter(filter: selectedFilter)
        self.dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? BaseTableViewCell else { return }
        cell.roundedCornersAndOffLastSeparatorVisibility(indexPath: indexPath, tableView: tableView)
    }
}
