//
//  CategoryListCell.swift
//  Tracker
//
//  Created by Ilya Lotnik on 12.08.2024.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    private var isLastCell: Bool = false {
        didSet {
            updateSeparatorVisibility()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        self.backgroundColor = .ypBackground
    }
    
    private func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
    private func updateSeparatorVisibility() {
        DispatchQueue.main.async {
            self.separatorInset = self.isLastCell ? UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude) : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func roundedCornersAndOffLastSeparatorVisibility(indexPath: IndexPath, tableView: UITableView) {
        
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let cornerRadius: CGFloat = 16.0
        
        if numberOfRows == 1 {
            roundCorners(corners: [.allCorners], radius: cornerRadius)
        } else if indexPath.row == 0 {
            roundCorners(corners: [.topLeft, .topRight], radius: cornerRadius)
        } else if indexPath.row == numberOfRows - 1 {
            roundCorners(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
        } else {
            roundCorners(corners: [], radius: 0)
        }
        
        isLastCell = (indexPath.row == numberOfRows - 1)
    }
}
