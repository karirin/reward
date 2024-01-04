//
//  RewardRegistrationView.swift
//  reward
//
//  Created by hashimo ryoya on 2023/08/22.
//

import SwiftUI
import Firebase

struct RewardRegistrationView: View {
    @State private var date: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600) // デフォルトで1時間後
    @EnvironmentObject private var authManager: AuthManager

    @State var title: String = "test"
    
    @State var content: String = "test"
    
    @State private var url: String = ""
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var buttonRect2: CGRect = .zero
    @State private var bubbleHeight2: CGFloat = 0.0
    @State private var tutorialNum: Int = 0

//    init(title: Binding<String> = .constant("")) {  // titleの初期化
//        self._title = title
//        UITextField.appearance().textColor = UIColor.black
//    }
    
    // この行を追加
    @Environment(\.presentationMode) var presentationMode
    @State private var isTimeInputEnabled: Bool = false // この変数を追加
    let screenHeight = UIScreen.main.bounds.height
    
    private var customDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        return formatter
    }

    var body: some View {
        ZStack{

            NavigationView {
                VStack {
                    HStack{
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                            Text("戻る")
                        }
                        .foregroundColor(Color("fontGray"))
                        .padding(.leading,5)
                        Spacer()
                        Text("ご褒美を投稿する")
                        Spacer()
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                            Text("戻る")
                        }
                        .padding(.trailing,5)
                        .opacity(0)
                    }
                    .padding(.bottom)
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
                                NavigationLink(destination: RewardKeywordRegistrationView(selectedKeyword: $title)) {
                                    HStack{
                                        Image(systemName: "magnifyingglass.circle")
                                        Text("キーワードから探す")
                                    }
                                    .padding(5)
                                    .foregroundColor(Color("fontGray"))
                                    .font(.system(size: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("fontGray"), lineWidth: 1)
                                    )
                                    .padding(.leading,3)
                                }
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
                                    //                                .labelsHidden() // ラベルを非表示にする
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
                                        .background(GeometryReader { geometry in
                                            Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                                        })
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
                    .background(GeometryReader { geometry in
                        Color.clear.preference(key: ViewPositionKey2.self, value: [geometry.frame(in: .global)])
                    })
                    .padding(.top)
                    .padding(.bottom)
                }
                .padding()
                .background(Color("Color"))
                
                .onPreferenceChange(ViewPositionKey.self) { positions in
        self.buttonRect = positions.first ?? .zero
    }
                .onPreferenceChange(ViewPositionKey2.self) { positions in
        self.buttonRect2 = positions.first ?? .zero
    }
//                .background(Color("Color"))
//                .edgesIgnoringSafeArea(.all)
                
            }
                        if tutorialNum == 2 {
                            GeometryReader { geometry in
                                Color.black.opacity(0.5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        
                                            .padding(-5)
                                            .frame(width: buttonRect.width, height: buttonRect.height)
                                            .position(x: buttonRect.midX, y: buttonRect.midY)
                                            .blendMode(.destinationOut)
                                    )
                                    .ignoresSafeArea()
                                    .compositingGroup()
                                    .background(.clear)
                        VStack {
                            Spacer()
                                .frame(height: buttonRect.minY - bubbleHeight)
                            VStack(alignment: .trailing, spacing: .zero) {
                            Image("上矢印")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.trailing, 25.0)
                                Text("ご褒美の予定を入力してださい。")
                                    .font(.system(size: 20.0))
                                    .padding(.all, 10.0)
                                    .background(Color.white)
                                    .cornerRadius(4.0)
                                    .padding(.horizontal, 3)
                                    .foregroundColor(Color("fontGray"))
                            }
                            .background(GeometryReader { geometry in
                                Path { _ in
                                    DispatchQueue.main.async {
                                        // ここで画面サイズに基づいて値を調整
                                        self.bubbleHeight = geometry.size.height - calculateOffset()
                                    }
                                }
                            })
                            Spacer()
                        }
                        .ignoresSafeArea()
                        .padding(.leading,40)
            
                            }
                            
                            .onTapGesture {
                                print("ontag")
                                if tutorialNum == 2 {
                                    tutorialNum = 3
                                    if let userId = authManager.user?.uid {
                                        authManager.updateTutorialNum(userId: userId, tutorialNum: 3) { success in
                                            // 成功時の処理をここに追加
                                        }
                                    } else {
                                        print("ユーザーIDがnilです")
                                    }
                                } else if tutorialNum == 3 {
                                    tutorialNum = 4
                                    if let userId = authManager.user?.uid {
                                        authManager.updateTutorialNum(userId: userId, tutorialNum: 4) { success in
                                            // 成功時の処理をここに追加
                                        }
                                    } else {
                                        print("ユーザーIDがnilです")
                                    }
                                }
                            }
                        //                            }
            
                                }
            if tutorialNum == 3 {
                GeometryReader { geometry in
                    Color.black.opacity(0.5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .frame(width: buttonRect2.width, height: buttonRect2.height)
                                .position(x: buttonRect2.midX, y: buttonRect2.midY)
                                .blendMode(.destinationOut)
                        )
                        .ignoresSafeArea()
                        .compositingGroup()
                        .background(.clear)
            VStack {
                Spacer()
                    .frame(height: buttonRect2.minY - bubbleHeight2)
                VStack(alignment: .trailing, spacing: .zero) {
                    Text("予定の入力が完了したら登録ボタンをクリックします。")
                        .font(.system(size: 20.0))
                        .padding(.all, 10.0)
                        .background(Color.white)
                        .cornerRadius(4.0)
                        .padding(.horizontal, 3)
                        .foregroundColor(Color("fontGray"))
                    Image("下矢印")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 25.0)
                }
                .background(GeometryReader { geometry in
                    Path { _ in
                        DispatchQueue.main.async {
                            self.bubbleHeight2 = geometry.size.height + 10
                        }
                    }
                })
                Spacer()
            }
            .ignoresSafeArea()
            .padding(.leading,40)

                }
                .onTapGesture {
                    print("ontag")
                    if tutorialNum == 2 {
                        tutorialNum = 3
                        if let userId = authManager.user?.uid {
                            authManager.updateTutorialNum(userId: userId, tutorialNum: 3) { success in
                                // 成功時の処理をここに追加
                            }
                        } else {
                            print("ユーザーIDがnilです")
                        }
                    } else if tutorialNum == 3 {
                        tutorialNum = 4
                        if let userId = authManager.user?.uid {
                            authManager.updateTutorialNum(userId: userId, tutorialNum: 4) { success in
                                // 成功時の処理をここに追加
                            }
                        } else {
                            print("ユーザーIDがnilです")
                        }
                    }
                }
            //                            }

                    }
        }
        .onAppear{
            print("buttonRect2.height:\(buttonRect.height)")
            authManager.setUser()
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
    }
    
    func calculateOffset() -> CGFloat {
        // 画面サイズに応じて異なる値を返す
        print("screenHeight:\(screenHeight)")
        if screenHeight < 700 { // iPhone SEなどの小さい画面サイズ
            return 560 // または必要に応じて調整
        } else { // iPhone 15などの大きい画面サイズ
            return 670 // または必要に応じて調整
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
        
        // startDateとendDateを作成
        let startDate = "\(formattedDate) \(formattedStartTime)"
        let endDate = "\(formattedDate) \(formattedEndTime)"
        
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
            "startDate": startDate,  // この行を追加
            "endDate": endDate,      // この行を追加
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

struct RewardRegistrationView_Previews: PreviewProvider {
    @State static private var dummyContent: String = ""
    static var authManager = AuthManager()

    static var previews: some View {
        RewardRegistrationView()
            .environmentObject(AuthManager())
    }
}
