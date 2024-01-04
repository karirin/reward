//
//  AuthManager.swift
//  BuildApp
//
//  Created by hashimo ryoya on 2023/04/29.
//

import SwiftUI
import Firebase

class AuthManager: ObservableObject {
  @Published var user: User?
  @Published var isLoading: Bool = true // この行を追加

  var isUserLoggedIn: Bool {
    return user != nil
  }

    
  var onLoginCompleted: (() -> Void)?
  
    func setUser() {
        user = Auth.auth().currentUser
        if let user = user {
            isLoading = false
            checkIfUserExists(userId: user.uid)
        } else {
            anonymousSignIn()
        }
    }

    func checkIfUserExists(userId: String) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                // ユーザーが存在しない場合、tutorialNumを0で設定
                self.initializeTutorialNumForUser(userId: userId)
            }
        })
    }

    func initializeTutorialNumForUser(userId: String) {
        let userRef = Database.database().reference().child("users").child(userId)
        let initialData = ["tutorialNum": 1]
        userRef.setValue(initialData) { error, _ in
            if let error = error {
                print("Error initializing tutorialNum: \(error)")
            } else {
                print("Initialized tutorialNum for new user")
            }
        }
    }

  
  func anonymousSignIn() {
    Auth.auth().signInAnonymously { result, error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
        self.isLoading = false
      } else if let result = result {
        print("Signed in anonymously with user ID: \(result.user.uid)")
        self.user = result.user
        self.checkLaunchCount()
      }
    }
  }
    
    func updateTutorialNum(userId: String, tutorialNum: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["tutorialNum": tutorialNum]

        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                print("test")
                completion(true)
            }
        }
    }

  func checkLaunchCount() {
    // アプリの起動回数を取得
    let launchCount = UserDefaults.standard.integer(forKey: "launchCount")
    
    // アプリが初めて起動された場合
    if launchCount == 0 {
      postSampleReward()
    }
    
    // 起動回数を更新
    UserDefaults.standard.set(launchCount + 1, forKey: "launchCount")
  }
  
    func postSampleReward() {
        // Realtime Databaseのリファレンスを取得
        let ref = Database.database().reference()

        // 現在の日時を取得し、1日前の日時を計算
        let now = Date()
        let oneDayInSeconds: TimeInterval = 24 * 60 * 60 // 1日の秒数
        let oneDayBefore = now.addingTimeInterval(-oneDayInSeconds)

        // 日付と時間のフォーマットを設定するためのDateFormatter
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()

        // 日付のフォーマットを設定（例: 2023-09-12）
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // 時間のフォーマットを設定（例: 10:00:00）
        timeFormatter.dateFormat = "HH:mm:ss"

        // フォーマットに基づいて1日前の日付と時間を文字列に変換
        let previousDate = dateFormatter.string(from: oneDayBefore)
        let previousTime = timeFormatter.string(from: oneDayBefore)
        
        guard let userID = user?.uid else {
          print("ユーザーIDの取得に失敗しました")
          return
        }
        
        // サンプルデータを作成
        var sampleRewardData: [String: Any] = [
          "content": "サウナ（サンプルデータ）",
          "date": previousDate,
          "startTime": previousTime,
          "endTime": previousTime, // 終了時間も必要に応じて調整
          "startDate": "\(previousDate) \(previousTime)",
          "endDate": "\(previousDate) \(previousTime)", // 終了日時も必要に応じて調整
          "title": "サンプル",
          "url": "https://sauna-ikitai.com/",
          "userID": userID // ここは実際のユーザーIDに置き換える必要があります
        ]
        
        // Realtime Databaseにサンプルデータを保存
        ref.child("rewards").childByAutoId().setValue(sampleRewardData) { (error, ref) in
          if let error = error {
            print("サンプルデータの保存に失敗しました: \(error.localizedDescription)")
          } else {
            print("サンプルデータを保存しました!")
          }
          self.isLoading = false
        }
    }

    
    func fetchTutorialNum(userId: String, completion: @escaping (Int?, Error?) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [String: Any],
               let tutorialNum = value["tutorialNum"] as? Int {
                // tutorialNumを正常に取得
                completion(tutorialNum, nil)
            } else {
                // tutorialNumが見つからないか、予期しないデータ型
                completion(nil, nil)
            }
        }) { error in
            // エラーが発生した場合
            completion(nil, error)
        }
    }
  
  func signout() {
    try? Auth.auth().signOut()
  }
}

struct AuthManager1: View {
  @ObservedObject var authManager = AuthManager()
  
  var body: some View {
    VStack {
      if authManager.user == nil {
        Text("Not logged in")
      } else {
        Text("Logged in with user ID: \(authManager.user!.uid)")
      }
      Button(action: {
        if self.authManager.user == nil {
          self.authManager.anonymousSignIn()
        }
      }) {
        Text("Log in anonymously")
      }
    }
  }
}

struct AuthManager_Previews: PreviewProvider {
  static var previews: some View {
    AuthManager1()
  }
}
