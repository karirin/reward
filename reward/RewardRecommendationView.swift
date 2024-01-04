//
//  RewardRecommendationView.swift
//  reward
//
//  Created by hashimo ryoya on 2023/08/23.
//

import SwiftUI

struct RewardRecommendationView: View {
    @State private var recommendedRewards: [String] = []

    var body: some View {
        List(recommendedRewards, id: \.self) { reward in
            Text(reward)
        }
        .onAppear() {
            fetchRecommendedRewards()
        }
    }

    func fetchRecommendedRewards() {
        // APIのエンドポイントURL
        let url = URL(string: "https://your-api-endpoint.com/rewards")!

        // URLSessionを使用してデータを取得
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // エラーハンドリング
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            if let data = data {
                do {
                    // デバッグ用: 取得したデータを文字列として出力
                    let dataString = String(data: data, encoding: .utf8)
                    print("Received data:\n\(dataString ?? "")")
                    
                    // JSONデータをデコード
                    let rewardsList = try JSONDecoder().decode([String].self, from: data)
                    DispatchQueue.main.async {
                        // UIの更新はメインスレッドで行う
                        self.recommendedRewards = rewardsList
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }

        }.resume()  // タスクを開始
    }
}

struct RewardRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        RewardRecommendationView()
    }
}
