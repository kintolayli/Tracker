//
//  ExtensionUIColor.swift
//  Tracker
//
//  Created by Ilya Lotnik on 28.11.2024.
//

import UIKit

extension UIColor {
    struct RGBAComponents {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
    }

    private func getRGBAComponents(from color: UIColor) -> RGBAComponents {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return RGBAComponents(red: red, green: green, blue: blue, alpha: alpha)
    }

    func isEqualToColor(_ color: UIColor) -> Bool {
        let selfComponents = getRGBAComponents(from: self)
        let colorComponents = getRGBAComponents(from: color)

        return selfComponents.red == colorComponents.red &&
            selfComponents.green == colorComponents.green &&
            selfComponents.blue == colorComponents.blue &&
            selfComponents.alpha == colorComponents.alpha
    }
}
