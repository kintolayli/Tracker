//
//  ExtensionUIViewController.swift
//  Tracker
//
//  Created by Ilya Lotnik on 27.11.2024.
//

import UIKit

extension UIViewController {
    
    func enableKeyboardDismissOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
