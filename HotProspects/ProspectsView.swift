
//  ProspectsView.swift
//  HotProspects
//
//  Created by Mohsin khan on 14/11/2025.
//

import CodeScanner
import SwiftUI
import SwiftData
import AVFoundation
import UserNotifications

struct ProspectsView: View {
    enum FilterType{
        case none, contacted, uncontacted
    }
    @Environment(\.modelContext) var modelContext
    @Query(sort:\Prospect.name) var prospects : [Prospect]
    @State private var isShowingScanner = false
    let filter : FilterType
    
    var title : String{
        switch filter {
        case .none:
            "EveryOne"
        case .contacted:
             "Contacted Peoples"
        case .uncontacted:
             "Uncontacted Peoples"
        }
    }
    
    var body: some View {
        NavigationStack{
            List(prospects){prospect in
                NavigationLink(destination: EditProspect(prospect: prospect)){
                    HStack{
                        VStack(alignment: .leading){
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if prospect.isContacted{
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }else{
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
                .swipeActions{
                    
                    Button("Delete" , systemImage: "trash" , role: .destructive){
                        modelContext.delete(prospect)
                    }
                    
                    if prospect.isContacted{
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
                                    prospect.isContacted.toggle()
                                }
                                .tint(.blue)
                    }else{
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark") {
                                    prospect.isContacted.toggle()
                                }
                                .tint(.green)
                        Button("Remind me" , systemImage: "bell"){
                            addNotification(for: prospect)
                        }
                        .tint(.orange)
                    }
                }
                .tag(prospect)
            }
                .navigationTitle(title)
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button("Scan" , systemImage: "qrcode.viewfinder"){
                            isShowingScanner = true
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading){
                        EditButton()
                    }
                }
                .sheet(isPresented: $isShowingScanner){
                    CodeScannerView(codeTypes: [.qr],simulatedData: "mohsin\nmohsin@gmail.com" ,completion: handleScan)
                }
        }
    }
    init(filter : FilterType){
        self.filter = filter
        
        if filter != .none{
            let showContactedOnly = filter == .contacted
            
            _prospects = Query(
                filter : #Predicate{prospect in
                    prospect.isContacted == showContactedOnly
                },
                sort: [SortDescriptor(\Prospect.name)]
                )
            
        }
        
    }
    func handleScan(result : Result<ScanResult , ScanError>){
        isShowingScanner = false
        
        switch result{
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else {return}
            
            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false)
            modelContext.insert(person)
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    func addNotification(for prospect : Prospect){
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

//            var dateComponents = DateComponents()
//            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                   center.add(request)
        }
        center.getNotificationSettings { settings in
           if settings.authorizationStatus == .authorized {
                addRequest()
           }else{
               center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                   if granted {
                       addRequest()
                   }else if let error {
                       print("Error requesting notification permission: \(error)")
                   }
               }
           }
        }
    }
}

#Preview {
    ProspectsView(filter: .none)
}
