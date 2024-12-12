//
//  SheduleTableViewCell.swift
//  Tracker
//
//  Created by Ilya Lotnik on 10.08.2024.
//

import UIKit


protocol SheduleTableViewCellDelegate: SheduleViewController {
    func switchValueChanged(isOn: Bool, cell: ScheduleTableViewCell)
}

final class ScheduleTableViewCell: BaseTableViewCell {
    weak var delegate: SheduleTableViewCellDelegate?
    static var reuseIdentifier = "SheduleListCell"

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 19, weight: .regular)
        return label
    }()

    private lazy var swith: UISwitch = {
        let swith = UISwitch()
        swith.onTintColor = .ypBlue
        return swith
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()

        swith.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .ypBackground
        accessoryType = .none
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        contentView.addSubviewsAndTranslatesAutoresizingMaskIntoConstraints([
            titleLabel,
            swith
        ])

        NSLayoutConstraint.activate( [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 244),

            swith.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            swith.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    @objc func switchChanged(_ sender: UISwitch) {
        delegate?.switchValueChanged(isOn: sender.isOn, cell: self)
    }

    func configure(with day: Day) {
        titleLabel.text = day.name
        swith.isOn = day.isActive
    }
}
