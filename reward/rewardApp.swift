//
//  rewardApp.swift
//  reward
//
//  Created by hashimo ryoya on 2023/08/21.
//

import SwiftUI
import Firebase

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  //    FirebaseApp.configure()
  return true
}

@main
struct rewardApp: App {
  @State private var showTodaysRewardOnLaunch: Bool = false
  @ObservedObject private var authManager = AuthManager()
  
  init() {
    FirebaseApp.configure()
    authManager.setUser()
    incrementLaunchCount()
  }
  
    func incrementLaunchCount() {
        let launchCountKey = "launchCount"
        let launchCount = UserDefaults.standard.integer(forKey: launchCountKey)
        UserDefaults.standard.set(launchCount + 1, forKey: launchCountKey)
    }
    
  var body: some Scene {
    WindowGroup {

          if isFirstLaunch() {
              SwipeableView() // 初回起動時に表示するビュー
                  .environmentObject(authManager)
                  .onAppear{
                      print("isFirstLaunch1:\(isFirstLaunch)")
                  }
          } else {
              if authManager.isLoading { // この行を変更
                  ActivityIndicator()
              } else {
              TopView(showTodaysRewardOnLaunch: $showTodaysRewardOnLaunch)
                  .environmentObject(authManager)
                  .onAppear{
                      print("isFirstLaunch2:\(isFirstLaunch)")
                  }
          }
      }
    }
    
  }
    func isFirstLaunch() -> Bool {
        let launchCount = UserDefaults.standard.integer(forKey: "launchCount")
        print(launchCount)
        return launchCount < 3
    }
}
