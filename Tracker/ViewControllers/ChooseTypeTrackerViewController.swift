//
//  ChooseTypeTrackerViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 07.08.2024.
//

import UIKit

protocol ChooseTypeTrackerViewControllerProtocol: AnyObject {
    var trackersViewController: TrackersViewControllerProtocol? { get set }
    var regularEventTrackerDelegate: SheduleEventTrackerViewControllerProtocol? { get set }
    var irregularEventTrackerDelegate: BaseEventTrackerViewControllerProtocol? { get set }
    func dismiss(animated: Bool)
}

final class ChooseTypeTrackerViewController: UIViewController {
    weak var trackersViewController: TrackersViewControllerProtocol?
    weak var regularEventTrackerDelegate: SheduleEventTrackerViewControllerProtocol?
    weak var irregularEventTrackerDelegate: BaseEventTrackerViewControllerProtocol?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Создание трекера"
        return label
    }()
    
    private let regularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
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
        view.backgroundColor = .ypWhite
        
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
        let viewController = CreateRegularEventTrackerViewController()
        viewController.chooseTypeTrackerViewController = self
        self.regularEventTrackerDelegate = viewController
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func irregularEventsButtonDidTap() {
        let viewController = CreateIrregularEventTrackerViewController()
        viewController.chooseTypeTrackerViewController = self
        self.irregularEventTrackerDelegate = viewController
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
