//
//  AppDelegate.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/11/24.
//

import UIKit
import ReSwift
import Firebase

var store: Store<AppState>!
let logger: Logger = Logger()
let networkMonitor: NetworkMonitor = NetworkMonitor()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Disable automatic screen lock while app is active
        UIApplication.shared.isIdleTimerDisabled = true
        // Start Firebase services
        FirebaseApp.configure()
        // Setup the Redux Store
        store = Store(
            reducer: appReducer,
            state: nil,
            middleware: [conversationMiddleware]
        )
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillResignActive(_ application: UIApplication) {
           // Optionally, re-enable the idle timer when the app is about to become inactive
           UIApplication.shared.isIdleTimerDisabled = false
       }

       func applicationDidBecomeActive(_ application: UIApplication) {
           // Disable the idle timer again when the app becomes active
           UIApplication.shared.isIdleTimerDisabled = true
       }
}

