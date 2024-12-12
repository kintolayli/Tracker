//
//  UIColorMarshalling.swift
//  Tracker
//
//  Created by Ilya Lotnik on 13.09.2024.
//

import UIKit

enum UIColorMarshalling {
    static func hexString(from color: UIColor) -> String {
        let components = color.cgColor.components
        let componentR: CGFloat = components?[0] ?? 0.0
        let componentG: CGFloat = components?[1] ?? 0.0
        let componentB: CGFloat = components?[2] ?? 0.0

        let hexString = String(
            format: "%02lX%02lX%02lX",
            lroundf(Float(componentR * 255)),
            lroundf(Float(componentG * 255)),
            lroundf(Float(componentB * 255))
        )

        return hexString
    }

    static func color(from hexString: String) -> UIColor {
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let componentR = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let componentG = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let componentB = CGFloat(rgb & 0x0000FF) / 255.0

        return UIColor(red: componentR, green: componentG, blue: componentB, alpha: 1.0)
    }
}
