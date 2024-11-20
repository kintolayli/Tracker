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
            return "Отслеживайте только то, что хотите"
        case .secondPage:
            return "Даже если это не литры воды и йога"
        }
    }
    
    var buttonName: String {
        return "Вот это технологии!"
    }
}
