//
//  RewardKeywordView.swift
//  reward
//
//  Created by hashimo ryoya on 2023/08/24.
//

import SwiftUI

struct RewardKeywordView: View {
    @State private var isRewardRegistrationViewPresented: Bool = false
    @State private var selectedRewardKeyword: String = ""
    @State private var selectedRewardTitle: String = ""
    @State private var selectedGenre: String? = nil
    let rewardKeywords1 = [
           "リラクゼーション": ["サウナ", "マッサージ", "スパ", "アロマセラピー", "ヨガ・ピラティス", "フェイシャルエステ", "ボディスクラブ", "ハンドマッサージ", "フットスパ"],
           "食事・デザート": ["デザート", "グルメディナー", "ワイン・シャンパン", "チョコレート", "ケーキ", "アイスクリーム", "カフェ巡り", "ティータイム", "バーベキュー", "ワインテイスティング", "チーズ試食", "クッキング・料理教室"],
           "アート・文化": ["読書", "映画鑑賞", "コンサート", "美術館・博物館", "ワークショップ", "手芸・クラフト", "ポットリー（陶芸）", "ペインティング", "ダンス", "ミュージカル鑑賞", "ジャズバー", "ブックカフェ"],
           "アウトドア・アクティビティ": ["旅行", "テーマパーク", "ビーチ", "ハイキング", "グランピング", "バルーンフライト", "フルーツピッキング", "ジェットスキー", "ホースライディング（乗馬）", "バンジージャンプ", "スカイダイビング", "シュノーケリング", "ダイビング","ガーデニング"],
           "ショッピング・ファッション": ["ショッピング", "美容院・ヘアサロン", "ネイルサロン", "ジュエリー"],
           "ペット・動物": ["ペットとの時間"],
           "エンターテインメント": ["パーティー", "カラオケ", "ボードゲーム", "バーチャルリアルティ体験"],
           "飲み物・食品製造": ["ショコラトリー（チョコレート工房）", "ブルワリー訪問（ビール醸造所）"]
       ]
    
    var body: some View {
        VStack{
            HStack{
                if selectedGenre != nil {
                    Button(action: {
                        self.selectedGenre = nil
                    }) {
                        Image(systemName: "chevron.left")
                        Text("戻る")
                    }
                    .padding()
                }
                Spacer()
                Text("キーワード一覧")
                    .font(.system(size: 20))
                Spacer()
                if selectedGenre != nil {
                    Button(action: {
                        self.selectedGenre = nil
                    }) {
                        Image(systemName: "chevron.left")
                        Text("戻る")
                    }
                    .padding()
                    .opacity(0)
                }
            }
            .frame(maxWidth:.infinity,maxHeight:60)
            .background(Color("plus"))
            .foregroundColor(Color("fontGray"))
            ScrollView {
                
                VStack(alignment: .leading) {
                    if selectedGenre == nil {
                        ForEach(Array(rewardKeywords1.keys.sorted()), id: \.self) { genre in
                            VStack(alignment: .leading){
                                HStack{
                                    Image(genre)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:10,height:50)
                                    
                                        .padding(.leading,30)
                                    Button(action: {
                                        self.selectedGenre = genre
                                    }) {
                                        Text(genre)
                                            .frame(maxWidth:.infinity,alignment: .leading)
                                            .font(.title2)
                                            .bold()
                                            .padding()
                                    }
                                    .padding(.leading,5)
                                }
                                Divider()
                            }
                            .frame(maxWidth:.infinity,alignment: .leading)
                            .foregroundColor(Color("fontGray"))
                        }
                    } else {
                        ForEach(Array(rewardKeywords1[selectedGenre!]!.enumerated()), id: \.element) { count, keyword in
                            HStack {
                                Button(action: {
                                    showRewardRegistrationView(with: keyword)
                                }) {
                                    Image(imageName(for: selectedGenre!, count: count))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:10,height:50)
                                        .padding()
                                    
                                        .padding(.leading,20)
                                    Text(keyword)
                                        .frame(maxWidth:.infinity,alignment: .leading)
                                        .font(.title2)
                                        .bold()
                                        .padding()
                                    
                                }
                                .foregroundColor(Color("fontGray"))
                            }
                            .frame(maxWidth:.infinity,alignment: .leading)
                            Divider()
                        }
                    }
                }
                .frame(maxWidth:.infinity)
            }
            .sheet(isPresented: $isRewardRegistrationViewPresented) {
                RewardRegistrationKeywordView(title: self.$selectedRewardTitle)
            }
        }
        .background(Color("Color"))
    }

    func showRewardRegistrationView(with keyword: String) {
        self.selectedRewardTitle = keyword
        self.isRewardRegistrationViewPresented = true
    }
    
    func imageName(for genre: String, count: Int) -> String {
        let genrePrefix: String
        switch genre {
        case "リラクゼーション":
            genrePrefix = "relaxation"
        case "食事・デザート":
            genrePrefix = "food"
        case "アート・文化":
            genrePrefix = "art"
        case "アウトドア・アクティビティ":
            genrePrefix = "outdoor"
        case "ショッピング・ファッション":
            genrePrefix = "shopping"
        case "ペット・動物":
            genrePrefix = "pet"
        case "エンターテインメント":
            genrePrefix = "entertainment"
        case "飲み物・食品製造":
            genrePrefix = "drink"
        case "その他":
            genrePrefix = "others"
        default:
            genrePrefix = "default"
        }
        return "\(genrePrefix)\(count)"
    }
}

struct RewardKeywordView_Previews: PreviewProvider {
    static var previews: some View {
        RewardKeywordView()
    }
}
