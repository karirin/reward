//
//  RewardListView.swift
//  reward
//
//  Created by hashimo ryoya on 2023/08/22.
//

import SwiftUI
import Firebase
import EventKit
import SwiftLinkPreview

struct RewardMouthView: View {
    @State private var rewards: [Reward] = []
    private var groupedRewards: [String: [Reward]] {
        Dictionary(grouping: rewards, by: { dateFormatter.string(from: $0.date) })
    }
    @State var showAnotherView_post: Bool = false
    @State private var showAlert: Bool = false
    @State private var hasTodaysReward: Bool = false
    @State private var isLoading: Bool = true
    @EnvironmentObject private var authManager: AuthManager
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var buttonRect2: CGRect = .zero
    @State private var bubbleHeight2: CGFloat = 0.0
    @State private var buttonRect3: CGRect = .zero
    @State private var bubbleHeight3: CGFloat = 0.0
    @State private var tutorialNum: Int = 0
    let screenHeight = UIScreen.main.bounds.height

    let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: DispatchQueue.global(), responseQueue: DispatchQueue.main, cache: DisabledCache.instance)

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var body: some View {
//        if isLoading {
//            // ローディング画面
//            VStack {
//                ProgressView()
//                Text("読み込み中...")
//            }
//        } else {
        ZStack{
            NavigationView {
                VStack{
                    HStack{
                        NavigationLink(destination: RewardListHistoryView()) {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                        .font(.system(size: 30))
                        .background(GeometryReader { geometry in
                            Color.clear.preference(key: ViewPositionKey3.self, value: [geometry.frame(in: .global)])
                        })
                        .padding()
                        .opacity(0)
                        Spacer()
                        Text("おすすめご褒美一覧")
                            .font(.system(size: 20))
                        Spacer()
                        NavigationLink(destination: RewardListHistoryView()) {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                        .font(.system(size: 30))
                        .padding()
                        .opacity(0)
                    }
                    .frame(maxWidth:.infinity,maxHeight:60)
                    .background(Color("plus"))
                    .foregroundColor(Color("fontGray"))
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(groupedRewards.keys.sorted(), id: \.self) { dateKey in
//                                if let rewardDate = dateFormatter.date(from: dateKey),
//                                   dateFormatter.string(from: rewardDate) >= dateFormatter.string(from: Date()) {
                                    VStack(alignment: .leading, spacing: 10) {
//                                        HStack{
//                                            Image(systemName: "calendar.circle")
//                                                .font(.system(size: 24))
//                                            Text(dateKey)
//                                                .font(.title2)
//                                                .fontWeight(.bold)
//                                        }
                                        ForEach(groupedRewards[dateKey]!, id: \.id) { reward in
                                            NavigationLink(destination: RewardDetailView(reward: reward)) {
                                                RewardHsitoryRow(reward: reward) { deletedReward in
                                                    self.deleteReward(reward: deletedReward)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        .shadow(radius: 1)
                                    }
//                                }
                            }
                        }
                        .background(GeometryReader { geometry in
                            Color.clear.preference(key: ViewPositionKey2.self, value: [geometry.frame(in: .global)])
                        })
                        .padding()
                        .padding(.bottom,80)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .background(Color("Color"))
            }
            .onPreferenceChange(ViewPositionKey.self) { positions in
                self.buttonRect = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey2.self) { positions in
                self.buttonRect2 = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey3.self) { positions in
                self.buttonRect3 = positions.first ?? .zero
            }
            .onChange(of: showAnotherView_post) { num in
                authManager.fetchTutorialNum(userId: authManager.user!.uid) { tutorialNum, error in
                                    if let error = error {
                                        print("エラーが発生しました: \(error.localizedDescription)")
                                    } else if let tutorialNum = tutorialNum {
                                        self.tutorialNum = tutorialNum
                                        print("取得したtutorialNum: \(tutorialNum)")
                                    } else {
                                        print("tutorialNumが見つかりませんでした")
                                    }
                                }
            }
            .onAppear() {
                authManager.setUser()
                print("authManager.user!.uid:\(authManager.user!.uid)")
                authManager.fetchTutorialNum(userId: authManager.user!.uid) { tutorialNum, error in
                    if let error = error {
                        print("エラーが発生しました: \(error.localizedDescription)")
                    } else if let tutorialNum = tutorialNum {
                        self.tutorialNum = tutorialNum
                        print("取得したtutorialNum: \(tutorialNum)")
                    } else {
                        print("tutorialNumが見つかりませんでした")
                    }
                }
                
                print("tutorialNum:\(tutorialNum)")

                if authManager.isUserLoggedIn {
                    self.fetchRewards()
                    self.checkTodaysReward()
                    self.isLoading = false
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if authManager.isUserLoggedIn {
                            self.fetchRewards()
                            self.checkTodaysReward()
                            self.isLoading = false
                        }
                    }
                }
            }
        }
        .onTapGesture {
            print("onTapGesturekkk")
            print("tutorialNum:\(tutorialNum)")
            if tutorialNum == 1 {
                tutorialNum = 2
                if let userId = authManager.user?.uid {
                    authManager.updateTutorialNum(userId: userId, tutorialNum: 2) { success in
                        // 成功時の処理をここに追加
                    }
                } else {
                    print("ユーザーIDがnilです")
                }
            }else if tutorialNum == 4 {
                tutorialNum = 5
                if let userId = authManager.user?.uid {
                    authManager.updateTutorialNum(userId: userId, tutorialNum: 5) { success in
                        // 成功時の処理をここに追加
                    }
                } else {
                    print("ユーザーIDがnilです")
                }
            }else if tutorialNum == 5 {
                tutorialNum = 6
                if let userId = authManager.user?.uid {
                    authManager.updateTutorialNum(userId: userId, tutorialNum: 6) { success in
                        // 成功時の処理をここに追加
                    }
                } else {
                    print("ユーザーIDがnilです")
                }
            }else if tutorialNum == 6 {
                tutorialNum = 0
                if let userId = authManager.user?.uid {
                    authManager.updateTutorialNum(userId: userId, tutorialNum: 0) { success in
                        // 成功時の処理をここに追加
                    }
                } else {
                    print("ユーザーIDがnilです")
                }
            }
        }
    }
    
    func fetchRewards() {
//        let ref = Database.database().reference().child("rewards")
        let group = DispatchGroup() // 非同期処理のグループを作成
        
        guard let userID = authManager.user?.uid else {
            print("ユーザーIDの取得に失敗しました")
            return
        }

        let ref = Database.database().reference().child("mouthRewards")
        ref.observe(.value) { (snapshot, errorString) in
            if let errorString = errorString {
                print("データの取得に失敗しました: \(errorString)")
                return
            }
            
            print("userID:\(userID)")
            
            var loadedRewards: [Reward] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let content = dict["content"] as? String,
                   let title = dict["title"] as? String,
                   let dateString = dict["date"] as? String,
                   let startTimeString = dict["startTime"] as? String,
                   let endTimeString = dict["endTime"] as? String {
                    
                    let dateFormatterForDate = DateFormatter()
                    dateFormatterForDate.dateFormat = "yyyy-MM-dd"
                    
                    let dateFormatterForTime = DateFormatter()
                    dateFormatterForTime.dateFormat = "HH:mm:ss"
                    
                    if let date = dateFormatterForDate.date(from: dateString),
                       let startTime = dateFormatterForTime.date(from: startTimeString),
                       let endTime = dateFormatterForTime.date(from: endTimeString),
                       let url = dict["url"] as? String,
                        let startDate = dict["startDate"] as? String,  // この行を追加
                        let endDate = dict["endDate"] as? String {    // この行を追加{
                        
//                        var reward = Reward(id: UUID(), content: content, date: date, startTime: startTime, endTime: endTime, title: title, url: url)
                        var reward = Reward(id: UUID(), content: content, date: date, startTime: startTime, endTime: endTime, startDate: startDate, endDate: endDate, title: title, url: url)  // この行を変更

                        reward.firebaseKey = childSnapshot.key
                        
                        if let urlString = reward.url {
                            group.enter() // 非同期処理の開始を通知
                            slp.preview(urlString, onSuccess: { result in
                                var newReward = Reward(id: reward.id, content: reward.content, date: reward.date, startTime: reward.startTime, endTime: reward.endTime, startDate: startDate, endDate: endDate, title: reward.title, url: reward.url)
                                newReward.previewTitle = result.title
                                newReward.previewDescription = result.description
                                newReward.previewImageURL = result.images?.first
                                newReward.firebaseKey = reward.firebaseKey
                                loadedRewards.append(newReward)
                                group.leave() // 非同期処理の終了を通知
                            }, onError: { error in
                                print("Error fetching URL preview: \(error)")
                                group.leave() // 非同期処理の終了を通知
                            })
                        } else {
                            loadedRewards.append(reward)
                        }
                    }
                    
                    group.notify(queue: .main) { // すべての非同期処理が完了したら
                        self.rewards = loadedRewards
                        print("rewards:\(self.rewards)")
                    }
                }
            }
        }
    }

    func checkTodaysReward() {
        // Realtime Databaseのリファレンスを取得
        let ref = Database.database().reference().child("rewards")

        // 今日の日付を取得
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())

        // 今日の日付のご褒美データを取得
        ref.child("rewards").queryOrdered(byChild: "date").queryEqual(toValue: today).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                // 今日の日付のご褒美データが存在する場合、アラートを表示
                self.hasTodaysReward = true
            }
        }
    }
    
    func fetchURLPreview(for reward: Reward) -> Reward {
        var updatedReward = reward
        slp.preview(reward.url ?? "test", onSuccess: { result in
            // プレビューの情報をupdatedRewardモデルに格納
            updatedReward.previewTitle = result.title
            updatedReward.previewDescription = result.description
            // 画像のURLも取得できる場合
            updatedReward.previewImageURL = result.images?.first
        }, onError: { error in
            print("Error fetching URL preview: \(error)")
        })
        return updatedReward
    }
    
    func deleteReward(reward: Reward) {
        // Firebaseのリファレンスを取得
        let ref = Database.database().reference().child("rewards")
        print("delete")
        // 該当のご褒美を削除
        if let key = reward.firebaseKey {
            print("delete1")
            ref.child(key).removeValue { (error, _) in
                if let error = error {
                    print("削除に失敗しました: \(error)")
                    return
                }
                
                // ローカルのリストからも削除
                if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
                    print("rewards:\(rewards)")
                    print("index:\(index)")
                    rewards.remove(at: index)
                }
            }
        }     else {
            print("Error: Firebase key is missing for the reward.")
        }
    }

}

struct RewardRow1: View {
    var reward: Reward
    var onDelete: (Reward) -> Void  // これを追加
    
    @State private var showingDeleteAlert = false
    @State private var rewardToDelete: Reward? = nil

    var body: some View {
        VStack(alignment: .leading) {
            Text(reward.title)
                .font(.system(size: 24))
                .padding(.bottom,5)
            Text(reward.content).font(.subheadline)
            
            // URLプレビューの画像とタイトルを表示
            if let imageURL = reward.previewImageURL, let url = URL(string: imageURL), let destinationURL = URL(string: reward.url ?? "") {
                Link(destination: destinationURL) { // ここでLinkコンポーネントを使用
                    VStack {
                        HStack{
                            AsyncImage(url: url) { response in
                                response.image?
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 100)
                            }
                            Spacer()
                        }
                        .frame(maxWidth:.infinity, alignment: .leading)
                        Text(reward.previewTitle ?? "")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth:.infinity, alignment: .leading)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
            }
            
            HStack{
                Button(action: {
                    Task {
                        //                    self.addEventToCalendar(title: reward.title, date: reward.date, startDate: reward.startDate, endDate: reward.endDate)
                        await requestAccess()
                    }
                }) {
                    HStack{
                        Image(systemName: "calendar.badge.plus")
                        Text("カレンダーに登録")
                    }
                    .padding(5)
                }

                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .foregroundColor(.gray)
                .padding(.top)
                Spacer()
                Button(action: {
                    self.rewardToDelete = self.reward
                    self.showingDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                    }
                    .padding(5)
                    .foregroundColor(.gray)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.top)
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(title: Text("削除確認"),
                          message: Text("ご褒美の\(reward.title)を削除してもよろしいですか？"),
                          primaryButton: .destructive(Text("削除")) {
                              if let reward = self.rewardToDelete {
                                  print("削除ボタンがクリックされました") // ここにログを追加
                                  self.onDelete(reward)
                              }
                          },
                          secondaryButton: .cancel())
                }
            }
        }
        .frame(maxWidth: .infinity,alignment: .leading)
        .padding()
        .background(.white)
        .cornerRadius(8)
        .onAppear{
            Task {
                print("requestAccess()")
                await requestAccess()
            }
        }
    }
    
//    func requestAccess() async {
//        let eventStore = EKEventStore()
//
//        if #available(iOS 17.0, *) {
//            // iOS 17.0以降の処理
//            print("iOS 17.0")
//            do {
//                try await eventStore.requestFullAccessToEvents { (granted, error) in
//                    handleAccessResponse(granted: granted, error: error)
//                }
//            } catch {
//                print("error: \(error.localizedDescription)")
//            }
//        } else {
//            print("iOS 15.0,iOS 16.0")
//            // iOS 15, 16の処理
//            eventStore.requestAccess(to: .event) { (granted, error) in
//                handleAccessResponse(granted: granted, error: error)
//            }
//        }
//    }
    
    func requestAccess() {
        let eventStore = EKEventStore()

        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { (granted, error) in
                // iOS 17.0以上での処理
                print("error:\(error)")
                print("granted:\(granted)")
                handleAccessResponse(granted: granted, error: error)
            }
        } else {
            // iOS 17.0より前のバージョンでの処理（古いAPIを使用）
            eventStore.requestAccess(to: .event) { (granted, error) in
                handleAccessResponse(granted: granted, error: error)
            }
        }
    }

    func handleAccessResponse(granted: Bool, error: Error?) {
        if let error = error {
            print("カレンダーへのアクセスリクエスト中にエラーが発生しました: \(error)")
            return
        }
        if granted {
            print("カレンダーへのアクセスが許可されました")
            // ここでイベントの挿入などの処理を行う
        } else {
            print("カレンダーへのアクセスが拒否されました")
        }
    }
    
    func addEventToCalendar(store: EKEventStore, title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = store.defaultCalendarForNewEvents

        do {
            try store.save(event, span: .thisEvent)
            print("イベントがカレンダーに追加されました")
        } catch {
            print("イベントの追加に失敗しました: \(error)")
        }
    }

    
//    func addEventToCalendar(title: String, date: Date, startDate: String, endDate: String) {
//        print()
//        let eventStore = EKEventStore()
//        print("EKEventStore.authorizationStatus(for: .event):\(EKEventStore.authorizationStatus(for: .event))")
//        switch EKEventStore.authorizationStatus(for: .event) {
//        case .authorized:
//            insertEvent(store: eventStore, title: title, startDate: startDate, endDate: endDate) // ここを変更
//        case .denied:
//            print("Access denied")
//        case .notDetermined:
//            eventStore.requestAccess(to: .event, completion:
//                { (granted: Bool, error: Error?) -> Void in
//                    if granted {
//                        self.insertEvent(store: eventStore, title: title, startDate: startDate, endDate: endDate)
//                    } else {
//                        print("Access denied")
//                    }
//                })
//        default:
//            print("Case Default")
//        }
//    }
    
    func stringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }

    func insertEvent(store: EKEventStore, title: String, startDate: String, endDate: String) {
        let event = EKEvent(eventStore: store)
        event.title = title
        
        if let startDateConverted = stringToDate(startDate), let endDateConverted = stringToDate(endDate) {
            event.startDate = startDateConverted
            event.endDate = endDateConverted
        } else {
            print("日付の変換に失敗しました。")
            return
        }
        
        event.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(event, span: .thisEvent)
        } catch let error as NSError {
            print("Error saving event: \(error)")
        }
    }


}

struct RewardMouthView_Previews: PreviewProvider {
    static var previews: some View {
        RewardMouthView()
            .environmentObject(AuthManager())
    }
}
