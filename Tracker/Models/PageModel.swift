//
//  PageModel.swift
//  Tracker
//
//  Created by Ilya Lotnik on 21.11.2024.
//

import Foundation

enum PageModel {
    case firstPage
    case secondPage
    
    var imageName: String {
        switch self {
        case .firstPage:
            return "startScreenImage1"
        case .secondPage:
            return "startScreenImage2"
        }
    }
    
    var labelName: String {
        switch self {
        case .firstPage:
            return L10n.PageModel.LabelName.firstPage
        case .secondPage:
            return L10n.PageModel.LabelName.secondPage
        }
    }
    
    var buttonName: String {
        return L10n.PageModel.buttonName
    }
}
