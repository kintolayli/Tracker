//
//  EmojiesColorCollectionViewCell.swift
//  Tracker
//
//  Created by Ilya Lotnik on 15.08.2024.
//

import UIKit

final class EmojiesColorCollectionViewCell: UICollectionViewCell {
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var colorSelectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
        view.layer.borderColor = ColorAsset.Color.ypColorSelection5.cgColor
        view.layer.opacity = 0.3
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    private lazy var emojiiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = ""
        label.font = .systemFont(ofSize: 32, weight: .medium)
        
        return label
    }()
    
    private lazy var emojiiLabelSelectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGray
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            colorSelectionView,
            colorView,
            emojiiLabelSelectionView,
            emojiiLabel
        ])
        
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            colorSelectionView.heightAnchor.constraint(equalToConstant: 52),
            colorSelectionView.widthAnchor.constraint(equalToConstant: 52),
            
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: colorSelectionView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: colorSelectionView.centerYAnchor),
            
            emojiiLabelSelectionView.heightAnchor.constraint(equalToConstant: 52),
            emojiiLabelSelectionView.widthAnchor.constraint(equalToConstant: 52),
            
            emojiiLabel.centerXAnchor.constraint(equalTo: emojiiLabelSelectionView.centerXAnchor),
            emojiiLabel.centerYAnchor.constraint(equalTo: emojiiLabelSelectionView.centerYAnchor),
            emojiiLabel.heightAnchor.constraint(equalToConstant: 40),
            emojiiLabel.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(
        backgroundColor: UIColor? = nil,
        emojiiLabelText: String? = nil,
        isHideColorViewSelection: Bool = true,
        isHideEmojiiLabelSelectionView: Bool = true
    ) {
        
        if let backgroundColor {
            colorView.backgroundColor = backgroundColor
        }
        
        if let emojii = emojiiLabelText {
            emojiiLabel.text = emojii
        }
        
        emojiiLabelSelectionView.isHidden = isHideEmojiiLabelSelectionView
        colorSelectionView.isHidden = isHideColorViewSelection
    }
}
