//
//  RewardRegistrationKeywordView.swift
//  reward
//
//  Created by hashimo ryoya on 2023/08/31.
//
import SwiftUI
import Firebase

struct RewardRegistrationKeywordView: View {
    @State private var date: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600) // デフォルトで1時間後
  @EnvironmentObject private var authManager: AuthManager

    @Binding var title: String

    init(title: Binding<String> = .constant("")) {  // titleの初期化
        self._title = title
        UITextField.appearance().textColor = UIColor.black
    }
    
    @State var content: String = ""
    
    @State private var url: String = ""
    
    // この行を追加
    @Environment(\.presentationMode) var presentationMode
    @State private var isTimeInputEnabled: Bool = false // この変数を追加
    
    private var customDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/M/d"
    return formatter
    }

    var body: some View {
        NavigationView {
                VStack(spacing: 20) {
                    ScrollView {
                        VStack(alignment: .leading){
                            HStack{
                                Text(" ")
                                    .frame(width:10,height: 20)
                                    .background(Color("plus"))
                                Text("ご褒美内容を入力")
                            }
                            .font(.system(size: 18))
                            TextField("旅行、サウナ", text: $title)
                                .border(Color.clear, width: 0)
                                .font(.system(size: 20))
                                .cornerRadius(8)
                            Divider()
                            
                        }
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text(" ")
                                    .frame(width:10,height: 20)
                                    .background(Color("plus"))
                                Text("URLを入力")
                            }
                            .font(.system(size: 18))
                            Text("ご褒美に関連するウェブページがあれば、そのURLをこちらに入力してください")
                                .foregroundColor(Color("fontGray"))
                                .font(.system(size: 14))
                                .lineLimit(nil) // この行を追加
                                .fixedSize(horizontal: false, vertical: true) // この行も追加
                            TextField("https://...com", text: $url)
                                .border(Color.clear, width: 0)
                                .font(.system(size: 20))
                                .cornerRadius(8)
                            Divider()
                        }
                        
                        VStack{
                            HStack{
                                Text(" ")
                                    .frame(width:10,height: 20)
                                    .background(Color("plus"))
                                Text("日付を入力")
                                    .font(.system(size: 18))
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .environment(\.locale, Locale(identifier: "ja_JP"))
                                    .border(Color.clear, width: 0)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Toggle(isOn: $isTimeInputEnabled) {
                            HStack{
                                Text(" ")
                                    .frame(width:10,height: 30)
                                    .background(Color("plus"))
                                Text("時間を入力")
                                    .font(.system(size: 18))
                            }
                        }
                        .padding(.trailing,2)
                        
                        if isTimeInputEnabled { // この条件を追加
                            VStack(alignment: .leading){
                                HStack{
                                    DatePicker("開始時間", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .border(Color.clear, width: 0)
                                        .cornerRadius(8)
                                        .foregroundColor(.secondary)
                                    DatePicker("終了時間", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .border(Color.clear, width: 0)
                                        .cornerRadius(8)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }else{
                            VStack(alignment: .leading){
                                Text("終日")
                                    .font(.system(size: 18))
                            }
                            .frame(height:36)
                        }
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text(" ")
                                    .frame(width:10,height: 30)
                                    .background(Color("plus"))
                                Text("メモを入力")
                                    .font(.system(size: 18))
                            }
                            TextField("何かメモをすることがあれば入力", text: $content)
                                .frame(maxHeight:.infinity, alignment: .top)
                                .border(Color.clear, width: 0)
                                .font(.system(size: 18))
                                .cornerRadius(8)
                        }
                    }
                    Spacer()
                    Button(action: {
                        saveReward()
                    }) {
                        Text("登録")
                            .frame(maxWidth:.infinity)
                    }
                    .frame(maxWidth:.infinity)
                    .padding()
                    .background(Color("gray"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top)
                    .padding(.bottom)
            }
                .padding()
                .padding(.top,10)
                .frame(maxWidth: .infinity, maxHeight:.infinity)
                .background(Color("Color"))
                .edgesIgnoringSafeArea(.all)
        }
    }

    func saveReward() {
        // Realtime Databaseのリファレンスを取得
        let ref = Database.database().reference()

        // DateFormatterを使用して日付と時間を指定された形式に変換
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)

        dateFormatter.dateFormat = "HH:mm:ss"
        
        // 終日の場合、時間を00:00〜23:59に設定
        let formattedStartTime: String
        let formattedEndTime: String
        if isTimeInputEnabled {
            formattedStartTime = dateFormatter.string(from: startTime)
            formattedEndTime = dateFormatter.string(from: endTime)
        } else {
            formattedStartTime = "00:00:00"
            formattedEndTime = "23:59:59"
        }
        
        guard let userID = authManager.user?.uid else {
            print("ユーザーIDの取得に失敗しました")
            return
        }

        // デフォルトのURLを設定
        let defaultURL = "https://example.com"  // ここにデフォルトのURLを設定します
        if url.isEmpty {
            url = defaultURL
        }

        let rewardData: [String: Any] = [
            "content": content,
            "date": formattedDate,
            "startTime": formattedStartTime,
            "endTime": formattedEndTime,
            "title": title,
            "url": url,
            "userID": userID
        ]

        // Realtime Databaseにデータを保存
        ref.child("rewards").childByAutoId().setValue(rewardData) { (error, ref) in
            if let error = error {
                print("データの保存に失敗しました: \(error.localizedDescription)")
            } else {
                print("データを保存しました!")
                
                // この行を追加して、ビューを閉じます
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }


}

struct RewardRegistrationKeywordView_Previews: PreviewProvider {
    @State static private var dummyContent: String = ""

    static var previews: some View {
        RewardRegistrationKeywordView()
    }
}

