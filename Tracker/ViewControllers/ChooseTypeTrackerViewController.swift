//
//  ChooseTypeTrackerViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 07.08.2024.
//

import UIKit

protocol ChooseTypeTrackerViewControllerProtocol: AnyObject {
    var trackersViewController: TrackersViewControllerProtocol? { get set }
    var eventTrackerDelegate: CreateEventTrackerViewControllerProtocol? { get set }
    func dismiss(animated: Bool)
}

final class ChooseTypeTrackerViewController: UIViewController {
    weak var trackersViewController: TrackersViewControllerProtocol?
    weak var eventTrackerDelegate: CreateEventTrackerViewControllerProtocol?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = NSLocalizedString("chooseTypeTrackerViewController.titleLabel.text", comment:"Page title")
        return label
    }()
    
    private lazy var regularEventButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedString("chooseTypeTrackerViewController.regularEventButton.title", comment:"Regular event button title")
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypMainBackground, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        let title =  NSLocalizedString("chooseTypeTrackerViewController.irregularEventButton.title", comment:"Irregular event button title")
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypMainBackground, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        view.backgroundColor = .ypMainBackground
        
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            titleLabel,
            regularEventButton,
            irregularEventButton
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            regularEventButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 350),
            regularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            regularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            regularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            regularEventButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularEventButton.topAnchor.constraint(equalTo: regularEventButton.bottomAnchor, constant: 16),
            irregularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        regularEventButton.addTarget(self, action: #selector(regularEventsButtonDidTap), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventsButtonDidTap), for: .touchUpInside)
    }
    
    @objc private func regularEventsButtonDidTap() {
        let viewController = CreateEventTrackerViewController()
        viewController.chooseTypeTrackerViewController = self
        self.eventTrackerDelegate = viewController
        viewController.didSelectCreateRegularEvent()
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func irregularEventsButtonDidTap() {
        let viewController = CreateEventTrackerViewController()
        viewController.chooseTypeTrackerViewController = self
        self.eventTrackerDelegate = viewController
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
    }
}

extension ChooseTypeTrackerViewController: ChooseTypeTrackerViewControllerProtocol {
    func dismiss(animated: Bool) {
        super.dismiss(animated: animated)
    }
}
