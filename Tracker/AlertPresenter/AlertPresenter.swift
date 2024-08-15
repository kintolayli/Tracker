//
//  AlertPresenter.swift
//  Tracker
//
//  Created by Ilya Lotnik on 11.08.2024.
//

import UIKit


final class AlertPresenter {
    
    static func show(model: AlertModel, viewController: UIViewController) {
        let alertController = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = "Alert"
        let action = UIAlertAction(title: model.buttonTitle, style: .default, handler: model.buttonAction)
        alertController.addAction(action)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
