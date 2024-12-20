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
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var emojiiLabelView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .ypWhite
        view.layer.opacity = 0.3
        return view
    }()
    
    private lazy var emojiiLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var pinImageView: UIImageView = {
        let view = UIImageView()
        view.image = ImageAsset.Image.pin
        view.tintColor = .ypWhite
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .ypWhite
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.text = L10n.daysCountLabel(0)
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var addButton: UIButton = {
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
                    addButtonState: Bool
    ){
        colorView.backgroundColor = cell.color
        emojiiLabel.text = cell.emojii
        titleLabel.text = cell.name
        addButton.backgroundColor = cell.color
        pinImageView.isHidden = cell.isPinned ? false : true
        
        updateButtonState(count: count, state: addButtonState, schedule: cell.schedule)
    }
    
    func updateButtonState(count: Int, state: Bool, schedule: [Day]?) {
        addButton.layer.opacity = state ? 0.3 : 1
        let imageName = state ? "checkmark" : "plus"
        addButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        if let _ = schedule {
            let localizedString = L10n.daysCountLabel(count)
            counterLabel.text = localizedString
        } else {
            let completed = L10n.TrackersCollectionViewCell.UpdateButtonState.completed
            let notCompleted = L10n.TrackersCollectionViewCell.UpdateButtonState.notCompleted
            counterLabel.text = state ? completed : notCompleted
        }
    }
    
    func getCounterText() -> String {
        guard let text = counterLabel.text else { return "error" }
        return text
    }
    
    @objc private func addButtonDidTap() {
        delegate?.trackersViewControllerCellTap(self)
    }
}
