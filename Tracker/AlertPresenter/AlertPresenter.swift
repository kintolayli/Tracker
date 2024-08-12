//
//  AlertPresenter.swift
//  Tracker
//
//  Created by Ilya Lotnik on 11.08.2024.
//

import UIKit


final class AlertPresenter {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func show(model: AlertModel) {
        guard let viewController = viewController else { return }
        
        let alertController = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = "Alert"
        let action = UIAlertAction(title: model.buttonTitle, style: .default, handler: model.buttonAction)
        alertController.addAction(action)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
