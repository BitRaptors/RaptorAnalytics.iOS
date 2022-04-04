//
//  File.swift
//  
//
//  Created by Vekety Robin on 2022. 04. 04..
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
internal extension EventLogType {
    var height: CGFloat {
        switch self {
        case .message:
            return 80
        default:
            return 40
        }
    }
    
    var iconName: String {
        switch self {
        case .message:
            return "message.fill"
        case .error:
            return "xmark.octagon.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .analytics:
            return "chart.bar.xaxis"
        }
    }
    
    func tintColor(for scheme: ColorScheme) -> Color {
        switch (self, scheme) {
        case (.message, .light):
            return .green
        case (.message, .dark):
            return Color(red: 48.0/255.0, green: 219.0/255.0, blue: 91.0/255.0)
        case (.error, .light):
            return .red
        case (.error, .dark):
            return Color(red: 255.0/255.0, green: 105.0/255.0, blue: 97.0/255.0)
        case (.warning, .light):
            return .yellow
        case (.warning, .dark):
            return Color(red: 255.0/255.0, green: 212.0/255.0, blue: 38.0/255.0)
        case (.analytics, .light):
            return .blue
        case (.analytics, .dark):
            return Color(red: 64.0/255.0, green: 156.0/255.0, blue: 255.0/255.0)
        }
    }
}
