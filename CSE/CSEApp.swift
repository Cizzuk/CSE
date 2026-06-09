//
//  CSEApp.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2022/07/23.
//

import SwiftUI
import UIKit

// MARK: - Global Constants

let currentVersion = CSEDataManager.currentVersion
let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
let currentRegion = Locale.current.region?.identifier
let userDefaults = CSEDataManager.userDefaults

// MARK: - App Entry Point

@main
struct CSEApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            MainView()
                #if targetEnvironment(macCatalyst)
                .onAppear {
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                        .titlebar?
                        .titleVisibility = .hidden
                }
                #endif
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                CloudKitManager().saveAll()
            }
        }
    }
}

// MARK: - App Delegate
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize app data and perform necessary updates
        AppInitializer.initializeApp()
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
