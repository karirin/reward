//
//  RewardListHistoryView.swift
//  reward
//
//  Created by hashimo ryoya on 2023/09/04.
//

import SwiftUI
import Firebase
import EventKit
import SwiftLinkPreview

struct RewardListHistoryView: View {
    @State private var rewards: [Reward] = []
    @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject private var authManager: AuthManager
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo") // 日本のタイムゾーンを設定
        return formatter
    }()
    
    @Binding var title: String
    @Binding var content: String
    @Binding var url: String

    init(title: Binding<String> = .constant(""), content: Binding<String> = .constant(""), url: Binding<String> = .constant("")) {
        self._title = title
        self._content = content
        self._url = url
        UITextField.appearance().textColor = UIColor.black
    }

    private var groupedRewards: [String: [Reward]] {
        Dictionary(grouping: rewards, by: { dateFormatter.string(from: $0.date) })
            .filter { key, _ in
                if let rewardDate = dateFormatter.date(from: key) {
                    let todayInJapan = dateFormatter.string(from: Date()) // 日本の今日の日付を取得
                    return key < todayInJapan
                }
                return false
            }
    }

    @State var showAnotherView_post: Bool = false
    @State private var showAlert: Bool = false
    @State private var hasTodaysReward: Bool = false
    @Environment(\.dismiss) var dismiss
    
    let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: DispatchQueue.global(), responseQueue: DispatchQueue.main, cache: DisabledCache.instance)

    var body: some View {
            NavigationView {
                VStack{
                    HStack{
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.left")
                            Text("戻る")
                        })
                        .padding()
                        Spacer()
                        Text("ご褒美一覧の履歴")
                            .font(.system(size: 20))
                        Spacer()
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.left")
                            Text("戻る")
                        })
                        .padding()
                        .opacity(0)
                    }
                    .frame(maxWidth:.infinity,maxHeight:60)
                    .background(Color("plus"))
                    .foregroundColor(Color("fontGray"))
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(groupedRewards.keys.sorted(by: >), id: \.self) { dateKey in // 降順にソート
                                               VStack(alignment: .leading, spacing: 10) {
                                                   HStack{
                                                       Image(systemName: "calendar.circle")
                                                           .font(.system(size: 24))
                                                       Text(dateKey)
                                                           .font(.title2)
                                                           .fontWeight(.bold)
                                                   }
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
                                           }
                                       }
                                       .padding()
                                   }
                    
                }.background(Color("Color"))
            }
        .onAppear() {
            self.fetchRewards()
            self.checkTodaysReward()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func fetchRewards() {
//        let ref = Database.database().reference().child("rewards")
        let group = DispatchGroup() // 非同期処理のグループを作成
        
        guard let userID = authManager.user?.uid else {
            print("ユーザーIDの取得に失敗しました")
            return
        }

        let ref = Database.database().reference().child("rewards")
        ref.queryOrdered(byChild: "userID").queryEqual(toValue: userID).observe(.value) { (snapshot, errorString) in
            if let errorString = errorString {
                print("データの取得に失敗しました: \(errorString)")
                return
            }
            
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
                       let endDate = dict["endDate"] as? String {
                        
//                        var reward = Reward(id: UUID(), content: content, date: date, startTime: startTime, endTime: endTime, title: title, url: url)
                        var reward = Reward(id: UUID(), content: content, date: date, startTime: startTime, endTime: endTime, startDate: startDate, endDate: endDate, title: title, url: url)
                        reward.firebaseKey = childSnapshot.key
                        print("childSnapshot.key:\(childSnapshot.key)")
                        print("reward.firebaseKey:\(reward.firebaseKey)")
                        
                        if let urlString = reward.url {
                            group.enter() // 非同期処理の開始を通知
                            slp.preview(urlString, onSuccess: { result in
                                var newReward = Reward(id: reward.id, content: reward.content, date: reward.date, startTime: reward.startTime, endTime: reward.endTime, startDate: reward.startDate, endDate: reward.endDate, title: reward.title, url: reward.url)
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

struct RewardHsitoryRow: View {
    var reward: Reward
    var onDelete: (Reward) -> Void  // これを追加
    
    @State private var showingDeleteAlert = false
    @State private var rewardToDelete: Reward? = nil
    
    @State var showRewardRegistrationView: Bool = false
    @State var selectedReward: Reward?
    @State private var showRewardRegistrationCopyView: Bool = false

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
                Spacer()
                Button(action: {
                    self.selectedReward = reward
                    self.showRewardRegistrationCopyView = true
                }, label: {
                    Image(systemName: "doc.on.doc")
                    Text("この予定をコピーする")
                })
                .padding(8)
                .foregroundColor(.gray)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity,alignment: .leading)
        .padding()
        .background(.white)
        .cornerRadius(8)
        .sheet(isPresented: $showRewardRegistrationCopyView) {
            RewardRegistrationCopyView(reward: reward)
        }
    }
    
    func addEventToCalendar(title: String, date: Date, startTime: Date, endTime: Date) {
        print()
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertEvent(store: eventStore, title: title, startDate: startTime, endDate: endTime) // ここを変更
        case .denied:
            print("Access denied")
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion:
                { (granted: Bool, error: Error?) -> Void in
                    if granted {
                        self.insertEvent(store: eventStore, title: title, startDate: startTime, endDate: endTime)
                    } else {
                        print("Access denied")
                    }
                })
        default:
            print("Case Default")
        }
    }
    
    func insertEvent(store: EKEventStore, title: String, startDate: Date, endDate: Date) { // 引数を変更
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate // ここを変更
        event.endDate = endDate // ここを変更
        event.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(event, span: .thisEvent)
        } catch let error as NSError {
            print("Error saving event: \(error)")
        }
    }

}

struct RewardListHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        RewardListHistoryView()
    }
}

