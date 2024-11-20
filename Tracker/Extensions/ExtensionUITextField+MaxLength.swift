//
//  ExtensionUITextField+LimitedSymbolCount.swift
//  Tracker
//
//  Created by Ilya Lotnik on 08.08.2024.
//

import UIKit

private var аssociationKeyMaxLength: Int = 0

extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &аssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &аssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc private func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
              prospectiveText.count > maxLength
        else {
            return
        }
        
        let selection = selectedTextRange
        
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        
        selectedTextRange = selection
    }
}
