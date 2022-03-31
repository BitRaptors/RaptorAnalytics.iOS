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

public enum EventLogType {
    case message
    case error
    case warning
    case analytics
}

public struct EventLogData: Identifiable {
    
    public let id: UUID = UUID()
    let title: String
    let message: String?
    let type: EventLogType
    
}

@available(iOS 14.0, *)
public class EventLog {
    
    public static let shared = EventLog()
    private var window: EventLogUIWindow?
    
    private let eventLogSubject = CurrentValueSubject<EventLogData?, Never>(nil)
    public var eventLogPublisher: AnyPublisher<[EventLogData], Never> {
        eventLogSubject.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    private init() { }
    
    public static func send(title: String, message: String? = nil, type: EventLogType = .message) {
        Self.shared.eventLogSubject.send(EventLogData(title: title, message: message, type: type))
    }
    
    public static func showLogs(on windowScene: UIWindowScene) {
        Self.shared.showLogs(windowScene)
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

@available(iOS 14.0, *)
public struct EventLogUI: View {
    
    @State
    var events: [EventLogData] = []
    
    public init() { }
    
    public var body: some View {
        List(events) { event in
            VStack {
                Divider()
                Text(event.title)
                    .font(Font.system(.title2, design: .default))
                if let message = event.message {
                    Text(message)
                        .font(Font.system(.body, design: .default))
                }
            }
        }
        .onReceive(EventLog.shared.eventLogPublisher) { eventLogData in
            events.append(eventLogData)
        }
    }
    
}

@available(iOS 14.0, *)
public class EventLogUIWindow: UIWindow {

    public override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        frame = UIScreen.main.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let eventLogController = rootViewController as? EventLogController else { return false }
        let eventLogControllerPoint = convert(point, to: eventLogController.view)
        return eventLogController.view.point(inside: eventLogControllerPoint, with: event)
    }
    
}

@available(iOS 14.0, *)
public class EventLogController: UIHostingController<EventLogUI> {
    
    init() {
        super.init(rootView: EventLogUI())
        view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
}
