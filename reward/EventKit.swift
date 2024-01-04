////
////  EventKit.swift
////  reward
////
////  Created by hashimo ryoya on 2023/08/22.
////
//
//import SwiftUI
//import EventKit
//
//struct EventKit: View {
//    var body: some View {
//        Button(action: {
//            addEventToCalendar(title: reward.title, date: reward.date)
//        }) {
//            Text("カレンダーに追加")
//                .padding()
//                .background(Color.green)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//        }
//
//    }
//    
//    func addEventToCalendar(title: String, date: Date) {
//        let eventStore = EKEventStore()
//        
//        switch EKEventStore.authorizationStatus(for: .event) {
//        case .authorized:
//            insertEvent(store: eventStore, title: title, date: date)
//        case .denied:
//            print("Access denied")
//        case .notDetermined:
//            eventStore.requestAccess(to: .event, completion:
//                {[weak self] (granted: Bool, error: Error?) -> Void in
//                    if granted {
//                        self?.insertEvent(store: eventStore, title: title, date: date)
//                    } else {
//                        print("Access denied")
//                    }
//                })
//        default:
//            print("Case Default")
//        }
//    }
//
//    func insertEvent(store: EKEventStore, title: String, date: Date) {
//        let event = EKEvent(eventStore: store)
//        event.title = title
//        event.startDate = date
//        event.endDate = date.addingTimeInterval(60*60) // 1 hour duration
//        event.calendar = store.defaultCalendarForNewEvents
//        do {
//            try store.save(event, span: .thisEvent)
//        } catch let error as NSError {
//            print("Error saving event: \(error)")
//        }
//    }
//
//}
//
//struct EventKit_Previews: PreviewProvider {
//    static var previews: some View {
//        EventKit()
//    }
//}
