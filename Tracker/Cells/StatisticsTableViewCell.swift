//
//  StatisticsTableViewCell.swift
//  Tracker
//
//  Created by Ilya Lotnik on 30.11.2024.
//

import UIKit

protocol StatisticsViewControllerDelegate: StatisticsViewController {
    
}


final class StatisticsTableViewCell: UITableViewCell {
    
    weak var delegate: StatisticsViewControllerDelegate?
    static var reuseIdentifier = "StatisticsTableViewCell"
    private var gradientBorderLayer: CAGradientLayer?
    
    private lazy var titleLabelNumber: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var titleLabelText: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabelNumber, titleLabelText])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 7
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGradientBackground()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        gradientBorderLayer?.frame = contentView.bounds
        gradientBorderLayer?.cornerRadius = 16
        if let shapeLayer = gradientBorderLayer?.mask as? CAShapeLayer {
            shapeLayer.path = UIBezierPath(roundedRect: contentView.bounds.insetBy(dx: 1, dy: 1), cornerRadius: 16).cgPath
        }
    }
    
    private func setupGradientBackground() {
        gradientBorderLayer?.removeFromSuperlayer()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColorMarshalling.color(from: "FD4C49").cgColor,
            UIColorMarshalling.color(from: "46E69D").cgColor,
            UIColorMarshalling.color(from: "007BFA").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        gradientLayer.frame = contentView.bounds
        
        let shapeLayer = CAShapeLayer()
        let borderWidth: CGFloat = 1
        shapeLayer.lineWidth = borderWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.path = UIBezierPath(
            roundedRect: contentView.bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2),
            cornerRadius: 16).cgPath
        
        gradientLayer.mask = shapeLayer
        
        contentView.layer.addSublayer(gradientLayer)
        gradientBorderLayer = gradientLayer
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        contentView.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            labelStackView
        ])
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate( [
            labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
    
    func configure(with data: (String, Int)) {
        titleLabelNumber.text = "\(data.1)"
        titleLabelText.text = data.0
    }
}
