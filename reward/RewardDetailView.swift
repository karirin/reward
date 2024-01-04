//
//  RewardDetailView.swift
//  reward
//
//  Created by hashimo ryoya on 2023/08/26.
//

import SwiftUI

struct RewardDetailView: View {
    var reward: Reward
    @Environment(\.presentationMode) var presentationMode
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()


    var body: some View {
        ScrollView {
            VStack(alignment: .leading,spacing: 15) {
                    HStack{
                        Text(" ")
                            .frame(width:10,height: 30)
                            .background(Color("plus"))
                        Text("ご褒美内容")
                    }
                    .font(.system(size: 24))
                    Text(reward.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                    
                    HStack{
                        Text(" ")
                            .frame(width:10,height: 30)
                            .background(Color("plus"))
                        Text("メモ内容")
                    }
                    .padding(.top)
                    .font(.system(size: 24))
                    Text(reward.content)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    
                    HStack{
                        Text(" ")
                            .frame(width:10,height: 30)
                            .background(Color("plus"))
                        Text("日付")
                    }
                    .padding(.top)
                    .font(.system(size: 24))
                
                HStack{
                    Text("\(dateFormatter.string(from: reward.date))")
                    Text("\(timeFormatter.string(from: reward.startTime))")
                    Text("〜")
                    Text("\(timeFormatter.string(from: reward.endTime))")
                }
               

                
                    if let imageURL = reward.previewImageURL, let url = URL(string: imageURL), let destinationURL = URL(string: reward.url ?? "") {
                        VStack(alignment: .leading) {
                            Link(destination: destinationURL) {
                                VStack(alignment: .leading){
                                    HStack{
                                        Text(" ")
                                            .frame(width:10,height: 20)
                                            .background(Color("plus"))
                                        Text("URL情報")
                                            .foregroundColor(.black)
                                    }
                                    .padding(.top)
                                    .font(.system(size: 24))
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
                                    
                                }
                            }
                            HStack{
                                Text(" ")
                                    .frame(width:10,height: 20)
                                    .background(Color("plus"))
                                Text("URL情報_タイトル")
                                    .foregroundColor(.black)
                            }
                            .padding(.top)
                            .font(.system(size: 24))
                            Text(reward.previewTitle ?? "")
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.black)
                                .frame(maxWidth:.infinity, alignment: .leading)
                            HStack{
                                Text(" ")
                                    .frame(width:10,height: 20)
                                    .background(Color("plus"))
                                Text("URL情報_詳細")
                                    .foregroundColor(.black)
                            }
                            .padding(.top)
                            .font(.system(size: 24))
                            Text(reward.previewDescription ?? "")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            .padding()
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .leading)
        .background(Color("Color"))
//        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
            Text("戻る")
        })
            .foregroundColor(.black)
    }
}


struct RewardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyReward = Reward(
            id: UUID(),
            content: "サンプルの内容",
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(60*60),
            startDate: "2023-08-26",  // この行を追加
            endDate: "2023-08-26",    // この行を追加
            title: "サンプルのタイトル",
            url: "https://sauna-ikitai.com/"
        )

        RewardDetailView(reward: dummyReward)
    }
}
