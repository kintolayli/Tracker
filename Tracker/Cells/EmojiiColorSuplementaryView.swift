//
//  EmojiiColorSuplementaryView.swift
//  Tracker
//
//  Created by Ilya Lotnik on 15.08.2024.
//

import UIKit


final class EmojiiColorSupplementaryView: UICollectionReusableView {
    private lazy var titleLabel: UILabel = {
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
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
