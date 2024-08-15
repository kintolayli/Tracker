//
//  AlertModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 11.08.2024.
//

import UIKit


struct AlertModel {
    let title: String
    let message: String
    let buttonTitle: String
    let buttonAction: ((UIAlertAction) -> Void)?
}
