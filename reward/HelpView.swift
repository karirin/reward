//
//  HelpView.swift
//  reward
//
//  Created by hashimo ryoya on 2024/01/04.
//

import SwiftUI

struct HelpView: View {
    @State private var isSheetPresented = false
    
    var body: some View {
        ZStack{
            Image(systemName: "circle.fill")
                .cornerRadius(30.0)
                .font(.system(size: 30))
                .foregroundColor(.white)
            VStack {
                Button(action: {
                    self.isSheetPresented = true
                }, label:  {
                    Image(systemName: "questionmark.circle")
                        .cornerRadius(30.0)
                        .foregroundColor(Color("lightYelleow"))
                        .font(.system(size: 40))
                    
                })
                
                
                //.shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
                .sheet(isPresented: $isSheetPresented, content: {
                    SwipeableView()
                    
                })
            }
        }
    }
}

struct SwipeableView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView{
            VStack {
                TabView(selection: $selectedTab) {
                    //                FirstView()
                    //                    .tag(0)
                    //                SecondView()
                    //                    .tag(1)
                    ThirdView()
                        .tag(0)
                    FourthView()
                        .tag(1)
                    FifthView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
                
                
                CustomPageIndicator2(numberOfPages: 3, currentPage: $selectedTab)
                    .padding(.bottom)
            }
        }
    }
}

struct CustomPageIndicator2: View {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.primary : Color.gray)
                    .frame(width: 10, height: 10)
                    .padding(.horizontal, 4)
            }
        }
    }
}

struct FirstView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .padding()
                Spacer()
                Text("チュートリアル")
                Spacer()
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .opacity(0)
                Spacer()
            }
            .background(Color("lightYelleow"))
            .foregroundColor(.white)
            Spacer()
            Image("トップ画面チュートリアル")
                .resizable()
                .scaledToFit()
            Spacer()
            VStack{
                HStack{
                    Image("レベル").resizable()
                        .frame(width:20,height:20)
                    Text("：ユーザーのレベルを表示しています")
                    Spacer()
                }
                HStack{
                    Image("ハート").resizable()
                        .frame(width:20,height:20)
                    Text("：ユーザーの体力を表示しています")
                    Spacer()
                }
                HStack{
                Image("ソード").resizable()
                    .frame(width:20,height:20)
                    Text("：ユーザーの攻撃力を表示しています")
                    Spacer()
                }
                HStack{
                    HStack{
                        Text("( + 20")
                        Image("ネッキー")
                            .resizable()
                            .frame(width: 20,height:20)
                        Text(")：")
                    }
                    Spacer()
                }
                Text("選択中のおともの体力と攻撃力がプラスされていることを表示しています")
            }.padding()
                .padding(.bottom,20)
            }
    }
}


struct SecondView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .padding()
                Spacer()
                Text("チュートリアル")
                Spacer()
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .opacity(0)
                Spacer()
            }
            .background(Color("lightYelleow"))
            .foregroundColor(.white)
            HStack{
                Text("各メニュー説明")
                    .font(.system(size: 24))
                Spacer()
            }
            .padding(.leading)
            ScrollView{
                Image("ダンジョン一覧")
                    .resizable()
                    .frame(height:70)
                    .padding(.horizontal)
                Text("難易度、種類別のクイズを選ぶことができます　")
                Image("ガチャトップ")
                    .resizable()
                    .frame(height:70)
                    .padding(.horizontal)
                Text("ガチャを回すことがで新しいおともを手に入れることができます")
                    .padding(.horizontal,5)
                Image("おとも図鑑")
                    .resizable()
                    .frame(height:70)
                    .padding(.horizontal)
                Text("手に入れたおともを確認することができます　　")
                HStack{
                    Image(systemName: "square.grid.2x2")
                        .resizable()
                        .frame(width:30, height:30)
                    Text("おとも一覧")
                        .font(.system(size: 24))
                    Spacer()
                }.padding(.horizontal)
                    .padding(.top,5)
                Text("選択中のおともを変えることができます　　　　")
                HStack{
                    Image(systemName: "chart.pie")
                        .resizable()
                        .frame(width:30, height:30)
                    Text("分析")
                        .font(.system(size: 24))
                    Spacer()
                }.padding(.horizontal)
                    .padding(.top,5)
                Text("日々の回答数や正答率をグラフで確認することができます")
                    .padding(.horizontal)
                Spacer()
            }
        }
    }
}

struct ThirdView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .padding()
                Spacer()
                Text("チュートリアル")
                Spacer()
                Text("")
                Spacer()
            }
            .background(Color("lightYelleow"))
            .foregroundColor(.white)
            Spacer()
            Text("予定を立てる")
                               .font(.system(size: 30))
            Image("チュートリアル画面１")
                .resizable()
                .scaledToFit()
                .frame(width:250,height:250)
                                .padding()
            Spacer()
            VStack{
                Text("このアプリは「自分へのご褒美」の\n予定を立てることができます")
                    .font(.system(size: 24))
                    .multilineTextAlignment(.center)
            Spacer()
                    .frame(height:100)
            }.padding(5)
        }
    }
}

struct FourthView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .padding()
                Spacer()
                Text("チュートリアル")
                Spacer()
                Text("")
                Spacer()
            }
            .background(Color("lightYelleow"))
            .foregroundColor(.white)
            Spacer()
            Text("カレンダーを確認")
              .font(.system(size: 30))
            Image("チュートリアル画面２")
                .resizable()
                .frame(width:250,height:250)
                .padding()
            Spacer()
            VStack{
                Text("カレンダーでご褒美の予定を\n一目でチェックすることができます")
                    .font(.system(size: 24))
                    .multilineTextAlignment(.center)
            Spacer()
                    .frame(height:100)
            }.padding(5)
        }
    }
}

struct FifthView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var authManager = AuthManager()
    @State private var flag: Bool = false
    @State private var showTodaysRewardOnLaunch: Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    }){
                        Text("閉じる")
                    }
                    .padding()
                    Spacer()
                    Text("チュートリアル")
                    Spacer()
                    Text("")
                    Spacer()
                }
                .background(Color("lightYelleow"))
                .foregroundColor(.white)
                Spacer()
                    Text("キーワードから探す")
                                        .font(.system(size: 30))
                Image("チュートリアル画面３")
                    .resizable()
                    .scaledToFit()
                    .padding(40)
                Spacer()
                VStack{
                    Text("ご褒美に関連したキーワードから\n予定を立てることができます")
                        .font(.system(size: 26))
                        .multilineTextAlignment(.center)
                    Button(action: {
                        self.flag = true
                    }) {
                        HStack {
                            Text("アプリをはじめる")
                                .padding(.vertical,10)
                                .padding(.horizontal,25)
                                .font(.headline)
                                .foregroundColor(.gray)
                                .background(RoundedRectangle(cornerRadius: 25)
                                    .fill(Color("plus")))
                            //                            .opacity(inputUserName.isEmpty ? 0.5 : 1.0)
                                .padding()
                        }
                    }
                    Spacer()
                        .frame(height:50)
                        
                }.padding(5)
            }
        }
        .background(
                   NavigationLink("", destination: TopView(showTodaysRewardOnLaunch: $showTodaysRewardOnLaunch).environmentObject(authManager).navigationBarBackButtonHidden(true), isActive: $flag)
       //                .hidden() // NavigationLinkを非表示にする
               )
                .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
//        HelpView()
//    FirstView()
//        SecondView()
//        FourthView()
//        FifthView()
        SwipeableView()
    }
}
