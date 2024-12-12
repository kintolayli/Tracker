//
//  AlertPresenter.swift
//  Tracker
//
//  Created by Ilya Lotnik on 11.08.2024.
//

import UIKit


enum AlertPresenter {
    static func show(model: AlertModel, viewController: UIViewController, preferredStyle: UIAlertController.Style = .alert ) {
        let alertController = UIAlertController(
            title: model.title, message: model.message, preferredStyle: preferredStyle
        )
        alertController.view.accessibilityIdentifier = "Alert"

        for actionModel in model.actions {
            let action = UIAlertAction(
                title: actionModel.title,
                style: actionModel.style,
                handler: actionModel.handler
            )
            alertController.addAction(action)
        }

        viewController.present(alertController, animated: true, completion: nil)
    }
}
