//
//  SupplementaryView.swift
//  Tracker
//
//  Created by Ilya Lotnik on 09.08.2024.
//

import UIKit


final class SupplementaryView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 21, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([titleLabel])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func updateLabel(text: String) {
        titleLabel.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
