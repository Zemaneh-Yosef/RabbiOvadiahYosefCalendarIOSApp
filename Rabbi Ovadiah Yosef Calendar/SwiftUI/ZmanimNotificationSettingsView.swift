//
//  ZmanimNotificationSettingsView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/25/25.
//

import SwiftUI

class ZmanimSettingsViewModel: ObservableObject {
    private let defaults = UserDefaults.getMyUserDefaults()

    @Published var notificationsOnShabbat: Bool {
        didSet {
            defaults.set(notificationsOnShabbat, forKey: "zmanim_notifications_on_shabbat")
            NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
        }
    }
    
    @Published var zmanimSettings: [String: Bool] = [:]
    @Published var zmanimMinutes: [String: Int] = [:]
    
    let editableZmanim = ["Alot Hashachar",
                           "Talit And Tefilin",
                           "Sunrise",
                           "Sof Zman Shma MGA",
                           "Sof Zman Shma GRA",
                           "Sof Zman Tefila",
                           "Achilat Chametz",
                           "Biur Chametz",
                           "Chatzot",
                           "Mincha Gedolah",
                           "Mincha Ketana",
                           "Plag HaMincha Halacha Berurah",
                           "Plag HaMincha Yalkut Yosef",
                           "Candle Lighting",
                           "Sunset",
                           "Tzeit Hacochavim",
                           "Tzeit Hacochavim (Stringent)",
                           "Fast Ends",
                           "Shabbat Ends",
                           "Rabbeinu Tam",
                           "Chatzot Layla"]
    
    init() {
        self.notificationsOnShabbat = defaults.bool(forKey: "zmanim_notifications_on_shabbat")
        
        for zman in editableZmanim {
            let notifyKey = "Notify" + zman
            let minutesKey = zman
            
            zmanimSettings[zman] = defaults.bool(forKey: notifyKey)
            zmanimMinutes[zman] = defaults.integer(forKey: minutesKey)
        }
    }
    
    func toggleNotification(for zman: String) {
        let notifyKey = "Notify" + zman
        zmanimSettings[zman]?.toggle()
        defaults.set(zmanimSettings[zman] ?? false, forKey: notifyKey)
        
        if zmanimSettings[zman] == false {
            defaults.set(-1, forKey: zman)
            zmanimMinutes[zman] = -1
        } else {
            defaults.set(0, forKey: zman)
            zmanimMinutes[zman] = 0
        }
        
        objectWillChange.send()
        NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
    }
    
    func updateMinutes(for zman: String, minutes: Int) {
        defaults.set(minutes, forKey: zman)
        zmanimMinutes[zman] = minutes
        objectWillChange.send()
        NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
    }
}

struct ZmanimNotificationsSettingsView: View {
    @StateObject private var viewModel = ZmanimSettingsViewModel()
    
    @State private var selectedZman: String? = nil
    @State private var zmanMinutesBefore: String = ""

    var body: some View {
        Form {
            Section {
                Toggle("Zemanim Notifications on Shabbat and Yom Tov", isOn: $viewModel.notificationsOnShabbat)
                Text("Receive zemanim notifications on shabbat and yom tov")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Section {
                Text("Select on the row of the zeman to change the amount of minutes")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            } header: {
                VStack {
                    Text("Minutes before the zeman for notifications").textCase(nil)
                }
            }
            
            Section {
                ForEach(viewModel.editableZmanim, id: \.self) { zman in
                    let isNotified = viewModel.zmanimSettings[zman] ?? false
                    let minutesBefore = viewModel.zmanimMinutes[zman] ?? -1
                    
                    let displayText: String = {
                        if minutesBefore >= 1 {
                            return "Notify ".localized().appending("\(minutesBefore)").appending(" minutes before".localized())
                        } else if minutesBefore == 0 {
                            return "Notify at the time of the zeman".localized()
                        } else {
                            return "Off".localized()
                        }
                    }()
                    
                    Button(action: {
                        if isNotified {
                            selectedZman = zman
                            zmanMinutesBefore = minutesBefore > 0 ? "\(minutesBefore)" : ""
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(zman
                                    .replacingOccurrences(of: "Plag HaMincha Halacha Berurah", with: "Pelag HaMincha (Halacha Berura)")
                                    .replacingOccurrences(of: "Plag HaMincha Yalkut Yosef", with: "Pelag HaMincha (Yalkut Yosef)")
                                    .localized())
                                    .foregroundColor(isNotified ? .primary : .gray)
                                Text(displayText)
                                    .font(.subheadline)
                                    .foregroundColor(isNotified ? .secondary : .gray)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.zmanimSettings[zman] ?? false },
                                set: { _ in viewModel.toggleNotification(for: zman) }
                            ))
                            .labelsHidden()
                        }
                    }
                }
            } header: {
                VStack {
                    Text("Editable Zemanim Notifications").textCase(nil)
                }
            }
        }
        .navigationTitle("Zemanim Notifications")
        .alert("Set Minutes Before Notification", isPresented: Binding(
            get: { selectedZman != nil },
            set: { if !$0 { selectedZman = nil } }
        )) {
            TextField("Minutes", text: $zmanMinutesBefore)
                .keyboardType(.numberPad)
            Button("Save") {
                if let zman = selectedZman, let minutes = Int(zmanMinutesBefore) {
                    viewModel.updateMinutes(for: zman, minutes: minutes)
                }
                selectedZman = nil
            }
            Button("Cancel", role: .cancel) {
                selectedZman = nil
            }
        }
    }
}


#Preview {
    ZmanimNotificationsSettingsView()
}
