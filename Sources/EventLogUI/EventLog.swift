//
//  __PROJECT_NAME__.swift
//  __PROJECT_NAME__
//
//  Created by Vekety Robin on Mar 30, 2022.
//  Copyright © 2022 BitRaptors. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

@available(iOS 15.0, *)
public class EventLog {
    
    internal static let shared = EventLog()
    private var window: EventLogUIWindow?
    
    @Published
    private var eventLogs: [EventLogData] = []
    internal var eventLogPublisher: AnyPublisher<[EventLogData], Never> {
        $eventLogs.eraseToAnyPublisher()
    }
    
    private init() { }
    
    public static func send(title: String, message: String? = nil, type: EventLogType = .analytics) {
        Self.shared.eventLogs.append(EventLogData(title: title, message: message, type: type))
    }
    
    public static func send(title: String, parameters: [String : Any], type: EventLogType = .analytics) {
        
        let message: String = parameters.map { (key, value) in
            "**\(key)**: \(value)\n"
        }
        .sorted()
        .reduce("") { partialResult, nextLine in
            partialResult + nextLine
        }
        
        send(title: title, message: message, type: type)
    }
    
    public static func showLogs(on windowScene: UIWindowScene) {
        Self.shared.showLogs(windowScene)
    }
    
    public static func hideLogs() {
        Self.shared.hideLogs()
    }
    
    private func showLogs(_ windowScene: UIWindowScene) {
        window = EventLogUIWindow(windowScene: windowScene)
        let controller = EventLogController()
        window?.rootViewController = controller
        window?.windowLevel = .statusBar
        window?.isHidden = false
    }
    
    private func hideLogs() {
        window?.isHidden = true
        window?.removeFromSuperview()
    }
    
}
