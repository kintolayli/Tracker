//
//  AlertActionModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 27.11.2024.
//

import UIKit

struct AlertActionModel {
    let title: String
    let style: UIAlertAction.Style
    let handler: ((UIAlertAction) -> Void)?
}
