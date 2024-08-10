//
//  ExtensionUIView.swift
//  Tracker
//
//  Created by Ilya Lotnik on 04.08.2024.
//

import UIKit


extension UIView {
    func addSubviewsAndTranslatesAutoresizingMaskIntoConstraints(_ subviews: [UIView]) {
        subviews.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @discardableResult func edgesToSuperView() -> Self {
        guard let superview = superview else {
            fatalError("View не в иерархии!")
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            leftAnchor.constraint(equalTo: superview.leftAnchor),
            rightAnchor.constraint(equalTo: superview.rightAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        ])
        return self
    }
}
