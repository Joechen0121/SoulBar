//
//  AppDelegate.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit
import AVFoundation
import FirebaseCore
import IQKeyboardManagerSwift
import YoutubeKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        try? AVAudioSession.sharedInstance().setCategory(.playback)
        
        IQKeyboardManager.shared.enable = true
        
        FirebaseApp.configure()
        
        configureNavigationBar()
        
        YoutubeKit.shared.setAPIKey("AIzaSyClrbLXP8jCneoelOAcq2VACJa0mTwbJLY")
        
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

    func configureNavigationBar() {
        
        UITabBar.appearance().barTintColor = K.Colors.customRed
        
        UITabBar.appearance().isTranslucent = true
        
        if #available(iOS 15.0, *) {
            
            let appearance = UITabBarAppearance()
            
            appearance.configureWithOpaqueBackground()
            
            appearance.backgroundColor = K.Colors.customRed
            
            UITabBar.appearance().standardAppearance = appearance
            
            UITabBar.appearance().scrollEdgeAppearance = UITabBar.appearance().standardAppearance
        }
        
        UINavigationBar.appearance().barTintColor = UIColor.white

        UINavigationBar.appearance().tintColor = UIColor(red: 246 / 255.0, green: 83 / 255.0, blue: 103 / 255.0, alpha: 1.0)

        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 246 / 255.0, green: 83 / 255.0, blue: 103 / 255.0, alpha: 1.0)]

        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 246 / 255.0, green: 83 / 255.0, blue: 103 / 255.0, alpha: 1.0)]
    }
}
