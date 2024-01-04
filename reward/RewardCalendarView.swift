//
//  RewardCalendarView.swift
//  reward
//
//  Created by hashimo ryoya on 2023/08/22.
//

import SwiftUI
import FSCalendar
import UIKit
import Firebase
import SwiftLinkPreview

struct RewardCalendarView: View {
    @State private var rewards: [Reward] = []
    @State private var selectedDate: Date? = nil
    @State private var shouldReloadData: Bool = false
    @State private var currentCalendarPage: Date = Date()
  @EnvironmentObject private var authManager: AuthManager

    let colors: [Color] = [Color("calendarRed"), Color("calendarBlue"), Color("calendarGreen"), Color("calendarYellow"), Color("calendarOrange"), Color("calendarPurple"), Color("calendarPink")]
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: DispatchQueue.global(), responseQueue: DispatchQueue.main, cache: DisabledCache.instance)
    
    let selectedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月" // 例: 2023年08月22日
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack {
                HStack{
                Text("")
                Spacer()
                    Text("\(selectedDateFormatter.string(from: currentCalendarPage))")
                        .font(.system(size: 20))
                Spacer()
                Text("")
            }
            .frame(maxWidth:.infinity,maxHeight:60)
            .background(Color("plus"))
            .foregroundColor(Color("fontGray"))
                FSCalendarWrapper(selectedDate: $selectedDate, shouldReloadData: $shouldReloadData, rewards: $rewards, currentCalendarPage: $currentCalendarPage) // この行を変更
                ZStack {
                    ScrollView {
                        LazyVStack {
                            let sortedRewards = rewards.sorted { $0.startTime < $1.startTime }
                            let filteredRewards = sortedRewards.filter { $0.date.isSameDay(as: selectedDate ?? Date()) }
                            
                            ForEach(filteredRewards.indices, id: \.self) { index in
                                let reward = filteredRewards[index]
                                    VStack {
                                        HStack{
                                            Image(systemName: "clock")
                                            Text(timeFormatter.string(from: reward.startTime))
                                            Text("〜")
                                            Text(timeFormatter.string(from: reward.endTime))
                                            Spacer()
                                        }
                                        .padding(.top)
                                        .padding(.leading,20)
                                        NavigationLink(destination: RewardDetailView(reward: reward)) {
                                        VStack(alignment: .leading) {
                                            HStack{
                                                Text(" ")
                                                    .frame(width:10,height: 100)
                                                    .background(colors[index % colors.count])
                                                if reward.content.isEmpty {
                                                    Text(reward.title).font(.system(size: 28))
                                                        .foregroundColor(.black)
                                                    Spacer()
                                                } else {
                                                    // contentが空でない場合
                                                    VStack{
                                                        Text(reward.title).font(.system(size: 28))
                                                            .frame(maxWidth:.infinity, alignment: .leading)
                                                            .foregroundColor(.black)
                                                        Text(reward.content).font(.subheadline)
                                                            .frame(maxWidth:.infinity, alignment: .leading)
                                                            .multilineTextAlignment(.leading)
                                                            .foregroundColor(.secondary)
                                                        Spacer()
                                                    }
                                                    .padding(.top)
                                                }
                                            }
                                        }
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 1)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                        }
                    }
                    .background(Color("Color"))
                }
            }
        }
        .onAppear {
            fetchRewards()
        }
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
            
            print("Number of rewards from Firebase: \(snapshot.childrenCount)")
            
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
                    dateFormatterForDate.timeZone = TimeZone(identifier: "Asia/Tokyo") // この行を追加

                    
                    let dateFormatterForTime = DateFormatter()
                    dateFormatterForTime.dateFormat = "HH:mm:ss"
                    
                    print("Date string: \(dateString), Start time string: \(startTimeString), End time string: \(endTimeString)")
                    
                    if let date = dateFormatterForDate.date(from: dateString),
                       let startTime = dateFormatterForTime.date(from: startTimeString),
                       let endTime = dateFormatterForTime.date(from: endTimeString),
                       let url = dict["url"] as? String,
                       let startDate = dict["startDate"] as? String,  // この行を追加
                       let endDate = dict["endDate"] as? String {
                        
                        var reward = Reward(id: UUID(), content: content, date: date, startTime: startTime, endTime: endTime,startDate: startDate, endDate: endDate, title: title, url: url)
                           reward.firebaseKey = childSnapshot.key
                        
                        if let urlString = reward.url {
                            group.enter() // 非同期処理の開始を通知
                            slp.preview(urlString, onSuccess: { result in
                                var newReward = Reward(id: reward.id, content: reward.content, date: reward.date, startTime: reward.startTime, endTime: reward.endTime, startDate: reward.startDate, endDate: reward.endDate, title: reward.title, url: reward.url)
                                newReward.previewTitle = result.title
                                newReward.previewDescription = result.description
                                newReward.previewImageURL = result.images?.first
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
                        print("Loaded rewards: \(loadedRewards)")
                        self.shouldReloadData = true // この行を追加
                    }
                }
            }
        }
    }
}

struct FSCalendarWrapper: UIViewRepresentable {
    @Binding var selectedDate: Date?
    @Binding var shouldReloadData: Bool  // この行を追加
    @Binding var rewards: [Reward]
    @Binding var currentCalendarPage: Date // この行を追加

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.locale = Locale(identifier: "ja_JP")
        calendar.headerHeight = 0.0  // この行を追加
        calendar.appearance.weekdayTextColor = .darkGray
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        if shouldReloadData {
            print("Reloading calendar data...")
            uiView.reloadData()
            DispatchQueue.main.async {
                self.shouldReloadData = false
            }
        }
    }


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: FSCalendarWrapper

        init(_ parent: FSCalendarWrapper) {
            self.parent = parent
        }
        
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            parent.$currentCalendarPage.wrappedValue = calendar.currentPage
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }

        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let weekday = Calendar.current.component(.weekday, from: date)
            if weekday == 7 || weekday == 1 { // 7は土曜日、1は日曜日
                return UIColor.gray // 灰色に変更
            }
            return nil // 他の曜日はデフォルトの色を使用
        }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let hasEvent = parent.rewards.contains(where: { $0.date.isSameDay(as: date) })  // この行を変更
            print("日付: \(date), イベント有無: \(hasEvent)")
            return hasEvent ? 1 : 0
        }
    }

}

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let selfComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let otherDateComponents = calendar.dateComponents([.year, .month, .day], from: otherDate)
        return selfComponents == otherDateComponents
    }
}


struct RewardCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        RewardCalendarView()
    }
}
