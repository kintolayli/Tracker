//
//  AlertModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 11.08.2024.
//

import UIKit


struct AlertModel {
    let title: String
    let message: String?
    let actions: [AlertActionModel]
    
    init(title: String, message: String?, buttonTitle: String = "OK", buttonAction: ((UIAlertAction) -> Void)? = nil) {
        self.title = title
        self.message = message
        self.actions = [AlertActionModel(title: buttonTitle, style: .default, handler: buttonAction)]
    }
    
    init(title: String, message: String?, actions: [AlertActionModel]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}
