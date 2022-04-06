//
//  SceneDelegate.swift
//  iOS Example
//
//  Created by Vekety Robin on 2022. 03. 31..
//

import SwiftUI
import UIKit
import Combine
import EventLogUI

@UIApplicationMain
class SceneDelegate: UIResponder, UIWindowSceneDelegate, UIApplicationDelegate {

    var disposeBag = Set<AnyCancellable>()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let rootView = ContentView()
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: rootView)
        self.window = window
        window.makeKeyAndVisible()
        
        if #available(iOS 15, *) {
        
            ///Message test
            
//            (0...20).map {
//                (title: "Title \($0)", message: "Message \($0) long text message for testing a purposes")
//            }
//            .publisher
//            .flatMap(maxPublishers: .max(1), { input -> AnyPublisher<(title: String, message: String?), Never> in
//                let randomDelay = 0.5//(1...3).randomElement()!
//                let randomDelayStride = RunLoop.SchedulerTimeType.Stride(Double(randomDelay))
//                return Just(input)
//                    .delay(for: randomDelayStride, scheduler: RunLoop.main)
//                    .eraseToAnyPublisher()
//            })
//            .sink { log in
//                EventLog.send(title: log.title, message: log.message, type: EventLogType.allCases.randomElement()!)
//            }
//            .store(in: &disposeBag)
            
            /// Param test
            
            (0...20).map { id -> (title: String, parameters: [String: Any]) in
                (title: "Title \(id) long title long long title long title long long long title", parameters: [
                    "type": "House",
                    "width": 200,
                    "color": UIColor.red,
                    "height": 100.0,
                    "timeOfPurchase": Date(),
                    "issue": URLError.cannotLoadFromNetwork,
                    "rooms": ["hall", "kitchen", "diningroom", "office", "garage", "bathroom"],
                    "roomProperties": [
                        [
                            "name": "hall",
                            "size": 4
                        ],
                        [
                            "name": "kitchen",
                            "size": 3
                        ],
                        [
                            "name": "diningroom",
                            "size": 5
                        ]
                    ]])
            }
            .publisher
            .flatMap(maxPublishers: .max(1), { input -> AnyPublisher<(title: String, parameters: [String: Any]), Never> in
                let randomDelay = 7//(1...7).randomElement()!
                let randomDelayStride = RunLoop.SchedulerTimeType.Stride(Double(randomDelay))
                return Just(input)
                    .delay(for: randomDelayStride, scheduler: RunLoop.main)
                    .eraseToAnyPublisher()
            })
            .sink { log in
                EventLog.send(title: log.title, parameters: log.parameters, type: EventLogType.allCases.randomElement()!)
            }
            .store(in: &disposeBag)
            
            EventLog.showLogs(on: windowScene)
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                EventLog.send(title: "Title 0 long title long long title long title long long long title",
//                              parameters: [
//                                    "type": "House",
//                                    "width": 200,
//                                    "color": UIColor.red,
//                                    "height": 100.0,
//                                    "timeOfPurchase": Date(),
//                                    "issue": URLError.cannotLoadFromNetwork,
//                                    "rooms": ["hall", "kitchen", "diningroom", "office", "garage", "bathroom"],
//                                    "roomProperties": [
//                                        [
//                                            "name": "hall",
//                                            "size": 4
//                                        ],
//                                        [
//                                            "name": "kitchen",
//                                            "size": 3
//                                        ],
//                                        [
//                                            "name": "diningroom",
//                                            "size": 5
//                                        ]
//                                    ]],
//                              type: EventLogType.allCases.randomElement()!)
//            }
            
        }
    }
}
