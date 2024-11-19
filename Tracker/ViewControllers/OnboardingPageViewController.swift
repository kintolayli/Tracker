//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 14.11.2024.
//

import UIKit

class OnboardingPageViewController: UIViewController {
    
    private let imageName: String
    private let labelName: String
    private let buttonName: String
    
    init(imageName: String, labelName: String, buttonName: String) {
        self.imageName = imageName
        self.labelName = labelName
        self.buttonName = buttonName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
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
        
        let backgroundImage = UIImage(named: imageName)
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        
        label.text = labelName
        button.setTitle(buttonName, for: .normal)
        
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            backgroundImageView,
            label,
            button,
        ])
        
        view.sendSubviewToBack(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
            
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60),
            
        ])
        
        button.addTarget(self, action: #selector(OkButtonDidTap), for: .touchUpInside)
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "isOnboardingHidden")
    }

    @objc func OkButtonDidTap() {
        completeOnboarding()
        self.dismiss(animated: true)
    }
}
