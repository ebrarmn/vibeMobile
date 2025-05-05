//
//  vibeComApp.swift
//  vibeCom
//
//  Created by EbrarMN on 25.04.2025.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth
import FirebaseCrashlytics
import FirebaseFirestore
import FirebaseStorage
import FirebaseMessaging
import FirebaseAnalytics


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct vibeComApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userSession = UserSession.shared
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @ObservedObject private var userSession = UserSession.shared
    var body: some View {
        if userSession.currentUser == nil {
            LoginView()
        } else {
            HomeView()
        }
    }
}
