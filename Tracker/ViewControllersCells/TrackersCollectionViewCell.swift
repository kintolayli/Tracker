//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Ilya Lotnik on 07.08.2024.
//

import UIKit

protocol TrackersCollectionViewCellDelegate: TrackersViewController {
    func trackersViewControllerCellTap(_ cell: TrackersCollectionViewCell)
    func getRecordsCountAndButtonLabelState(indexPath: IndexPath) -> (Int, Bool)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackersCollectionViewCell"
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiiLabelView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .ypWhite
        view.layer.opacity = 0.3
        return view
    }()
    
    private let emojiiLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private var pinImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pinImage")
        view.tintColor = .ypWhite
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .ypWhite
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.text = "0 дней"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.tintColor = .ypWhite
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            colorView,
            emojiiLabelView,
            emojiiLabel,
            pinImageView,
            titleLabel,
            counterLabel,
            addButton
        ])
        
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiiLabelView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiiLabelView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiiLabelView.widthAnchor.constraint(equalToConstant: 24),
            emojiiLabelView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiiLabel.centerXAnchor.constraint(equalTo: emojiiLabelView.centerXAnchor),
            emojiiLabel.centerYAnchor.constraint(equalTo: emojiiLabelView.centerYAnchor),
            
            pinImageView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -4),
            pinImageView.widthAnchor.constraint(equalToConstant: 24),
            pinImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 44),
            titleLabel.centerXAnchor.constraint(equalTo: colorView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 143),
            titleLabel.heightAnchor.constraint(equalToConstant: 34),
            
            counterLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 54),
            
            addButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34),
        ])
        
        addButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(cell: Tracker,
                    count: Int,
                    addButtonState: Bool,
                    isPin: Bool = false
    ){
        colorView.backgroundColor = cell.color
        emojiiLabel.text = cell.emojii
        titleLabel.text = cell.name
        addButton.backgroundColor = cell.color
        pinImageView.isHidden = isPin ? false : true
        
        updateButtonState(count: count, state: addButtonState, schedule: cell.schedule)
    }
    
    private func determineEndOfWord(number: Int) -> String {
        let remainder = number % 10
        if remainder == 1 && number % 100 != 11 {
            return "день"
        } else if (2...4).contains(remainder) && !(12...14).contains(number % 100) {
            return "дня"
        } else {
            return "дней"
        }
    }
    
    func updateButtonState(count: Int, state: Bool, schedule: [Day]?) {
        addButton.layer.opacity = state ? 0.3 : 1
        let imageName = state ? "checkmark" : "plus"
        addButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        if let _ = schedule {
            let dayWord = determineEndOfWord(number: count)
            counterLabel.text = "\(count) \(dayWord)"
        } else {
            counterLabel.text = state ? "Выполнено" : "Не выполнено"
        }
    }
    
    @objc private func addButtonDidTap() {
        delegate?.trackersViewControllerCellTap(self)
    }
}
