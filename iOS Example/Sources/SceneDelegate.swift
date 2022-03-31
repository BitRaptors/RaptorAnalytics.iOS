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
    var secondWindow: UIWindow?
    
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
        
//        secondWindow = UIWindow(windowScene: windowScene)
//        secondWindow?.frame = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.size.width, height: 100)
//        let someView = Text("I am on top of everything")
//        secondWindow?.rootViewController = UIHostingController(rootView: someView)
//        secondWindow?.windowLevel = .statusBar
//        secondWindow?.isHidden = false
        
        (0...20).map {
            (title: "Title \($0)", message: "Message \($0) long text message for testing purposes")
        }
        .publisher
        .flatMap(maxPublishers: .max(1), { input -> AnyPublisher<(title: String, message: String?), Never> in
            let randomDelay = (1...3).randomElement()!
            let randomDelayStride = RunLoop.SchedulerTimeType.Stride(Double(randomDelay))
            return Just(input)
                .delay(for: randomDelayStride, scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        })
        .sink { log in
            EventLog.send(title: log.title, message: log.message)
        }
        .store(in: &disposeBag)
        
        EventLog.showLogs(on: windowScene)
        
        EventLog.shared.eventLogPublisher.sink { eventData in
            print(eventData)
        }.store(in: &disposeBag)

//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            print("window: \(EventLog.shared.window)")
//        }
    }
}
