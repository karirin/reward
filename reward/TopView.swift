//
//  TopView.swift
//  reward
//
//  Created by hashimo ryoya on 2023/08/23.
//

import SwiftUI
import Firebase

struct TopView: View {
    @Binding var showTodaysRewardOnLaunch: Bool
  @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        NavigationView{
            VStack {
                TabView {
                    ZStack {
                        RewardListView()
                            .background(Color("Color"))
                    }
                    .tabItem {
                        Image(systemName: "house")
                            .padding()
                        Text("ホーム")
                            .padding()
                    }
                    
                    ZStack {
                        RewardCalendarView()
                    }
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("カレンダー")
                    }
                    
                    ZStack {
                        RewardMouthView()
                    }
                    .tabItem {
                        Image(systemName: "gift")
                        Text("おすすめご褒美")
                    }
                    
                    RewardKeywordView()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("キーワード")
                        }
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("設定")
                        }
                }
            }
        }
        .onAppear(perform: checkTodaysReward)
        .alert(isPresented: $showTodaysRewardOnLaunch) {
            Alert(title: Text("お知らせ"), message: Text("今日はご褒美の日です！"), dismissButton: .default(Text("OK")))
        }
    }
    
    func checkTodaysReward() {
        // Realtime Databaseのリファレンスを取得
        let ref = Database.database().reference()

        // 今日の日付を取得
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        guard let userID = authManager.user?.uid else {
            print("ユーザーIDの取得に失敗しました")
            return
        }

        // ユーザーIDに基づいてデータをフィルタリング
        ref.child("rewards").queryOrdered(byChild: "userID").queryEqual(toValue: userID).observeSingleEvent(of: .value) { (snapshot) in
            var isRewardToday = false
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let rewardDate = dict["date"] as? String {
                    if rewardDate == today {
                        isRewardToday = true
                        break
                    }
                }
            }
            if isRewardToday {
                self.showTodaysRewardOnLaunch = true
            }
        }
    }

}

struct TopView_Previews: PreviewProvider {
    static var authManager = AuthManager()
    
    static var previews: some View {
        TopView(showTodaysRewardOnLaunch: .constant(false))
            .environmentObject(authManager)
    }
}
