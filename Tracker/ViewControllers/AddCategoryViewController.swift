//
//  AddCategoryViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 09.08.2024.
//

import UIKit

protocol AddCategoryViewControllerProtocol: AnyObject {
    var categoryListViewController: CategoryListViewControllerProtocol? { get set }
}

final class AddCategoryViewController: UIViewController, AddCategoryViewControllerProtocol {
    
    private lazy var trackerCategoryStore: TrackerCategoryStore = {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            assertionFailure(TrackersViewControllerError.loadContextError.localizedDescription)
            
            let fallbackContext = DefaultContext(concurrencyType: .mainQueueConcurrencyType)
            return TrackerCategoryStore(context: fallbackContext)
        }
        return TrackerCategoryStore(context: context)
    }()
    
    weak var categoryListViewController: CategoryListViewControllerProtocol?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = NSLocalizedString("addCategoryViewController.titleLabel.text", comment: "Page title")
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("addCategoryViewController.textField.placeholder", comment: "Text field placeholder")
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
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedString("addCategoryViewController.okButton.title", comment: "Button title")
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func okButtonIsEnable() {
        okButton.setTitleColor(.ypMainBackground, for: .normal)
    }
    
    private func setupUI() {
        view.backgroundColor = .ypMainBackground
        view.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            titleLabel,
            textField,
            okButton
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            textField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            okButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            okButton.heightAnchor.constraint(equalToConstant: 60),
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        okButton.addTarget(self, action: #selector(okButtonDidTap), for: .touchUpInside)
        okButton.isEnabled = false
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        enableKeyboardDismissOnTap()
    }
    
    @objc private func okButtonDidTap() {
        guard let text = textField.text else { return }
        categoryListViewController?.viewModel.saveCategory(text: text)
        self.dismiss(animated: true)
    }
    
    @objc private func clearText() {
        textField.text = ""
        textField.sendActions(for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            textField.rightViewMode = .always
        } else {
            textField.rightViewMode = .never
        }
        
        okButton.isEnabled = !(textField.text?.isEmpty ?? true)
        okButton.backgroundColor = okButton.isEnabled ? .ypBlack : .ypGray
        
        if traitCollection.userInterfaceStyle == .dark {
            if okButton.isEnabled {
                okButton.setTitleColor(.ypAlwaysBlack, for: .normal)
            } else {
                okButton.setTitleColor(.ypWhite, for: .normal)
            }
        }
    }
}
