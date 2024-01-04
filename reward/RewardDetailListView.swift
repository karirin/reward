//
//  RewardDetailListView.swift
//  reward
//
//  Created by hashimo ryoya on 2023/08/23.
//
import SwiftUI
import Firebase

struct RewardDetailListView: View {
    @State private var rewards: [Reward] = []
    @State private var selectedDate: Date? = nil
    
    var body: some View {
        VStack {
            List {
                let filteredRewards = rewards.filter { $0.date.isSameDay(as: selectedDate ?? Date()) }

                ForEach(filteredRewards, id: \.id) { reward in
                    VStack(alignment: .leading) {
                        Text(reward.title).font(.headline)
                        Text(reward.content).font(.subheadline)
                    }
                }
            }
        }
        .onAppear {
            fetchRewards()
        }
    }
    
    // この関数をViewの本体の外に移動
    func fetchRewards() {
        let ref = Database.database().reference().child("rewards")
        ref.observeSingleEvent(of: .value) { (snapshot, errorString) in
            if let errorString = errorString {
                print("データの取得に失敗しました: \(errorString)")
                return
            }
            
            if let rewardsData = snapshot.value as? [String: [String: Any]] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

                self.rewards = rewardsData.compactMap { (key, data) in
                    guard let content = data["content"] as? String,
                          let dateString = data["date"] as? String,
                          let date = dateFormatter.date(from: dateString),
                          let title = data["title"] as? String else {
                        return nil
                    }
                    return Reward(id: UUID(), content: content, date: date, title: title)
                }
            }
            print("取得したデータ: \(self.rewards)")
        }
    }
}

struct RewardDetailListView_Previews: PreviewProvider {
    static var previews: some View {
        RewardDetailListView()
    }
}
