//
//  AppDelegate.swift
//  SimpleTODOApp
//
//  Created by Konstantin Tsistjakov on 18.11.2022.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }

    // MARK: - Remote notification
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
    }
}
