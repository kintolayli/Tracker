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
            return NSLocalizedString("pageModel.labelName.firstPage", comment:"Onboarding page message")
        case .secondPage:
            return NSLocalizedString("pageModel.labelName.secondPage", comment:"Onboarding page message")
        }
    }
    
    var buttonName: String {
        return NSLocalizedString("pageModel.buttonName", comment:"Button title")
    }
}
