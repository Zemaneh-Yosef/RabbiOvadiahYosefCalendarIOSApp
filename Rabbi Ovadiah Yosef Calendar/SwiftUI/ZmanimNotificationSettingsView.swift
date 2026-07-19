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
    
    func replaceWithDisplayName(zmanName: String) -> String {
        let zmanimNames = ZmanimTimeNames(defaults: defaults)
        switch zmanName {
        case "Alot Hashachar":
            return zmanimNames.getAlotString()
        case "Sunrise":
            return zmanimNames.getHaNetzString()
        case "Talit And Tefilin":
            return zmanimNames.getTalitTefilinString()
        case "Sof Zman Shma MGA":
            return zmanimNames.getShmaMgaString()
        case "Sof Zman Shma GRA":
            return zmanimNames.getShmaGraString()
        case "Sof Zman Tefila":
            return zmanimNames.getBrachotShmaString()
        case "Achilat Chametz":
            return zmanimNames.getAchilatChametzString()
        case "Biur Chametz":
            return zmanimNames.getBiurChametzString()
        case "Chatzot":
            return zmanimNames.getChatzotString()
        case "Mincha Gedolah":
            return zmanimNames.getMinchaGedolaString()
        case "Mincha Ketana":
            return zmanimNames.getMinchaKetanaString()
        case "Plag HaMincha Halacha Berurah":
            return "\(zmanimNames.getPlagHaminchaString()) (\(zmanimNames.getHalachaBerurahString()))"
        case "Plag HaMincha Yalkut Yosef":
            return "\(zmanimNames.getPlagHaminchaString()) (\(zmanimNames.getYalkutYosefString()))"
        case "Candle Lighting":
            if defaults.object(forKey: "candleLightingOffset") != nil {
                return "\(zmanimNames.getCandleLightingString()) (\(defaults.integer(forKey: "candleLightingOffset")))"
            }
            return "\(zmanimNames.getCandleLightingString()) (20)"
        case "Sunset":
            return zmanimNames.getSunsetString()
        case "Tzeit Hacochavim":
            return zmanimNames.getTzaitHacochavimString()
        case "Tzeit Hacochavim (Stringent)":
            return "\(zmanimNames.getTzaitHacochavimString()) \(zmanimNames.getLChumraString())"
        case "Fast Ends":
            return zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString()
        case "Shabbat Ends":
            return zmanimNames.getTzaitString() + getShabbatChagString() + zmanimNames.getEndsString()
        case "Rabbeinu Tam":
            return zmanimNames.getRTString()
        case "Chatzot Layla":
            return zmanimNames.getChatzotLaylaString()
        default:
            return ""
        }
    }
    
    private func getShabbatChagString() -> String {
        let hebrew = defaults.bool(forKey: "isZmanimInHebrew")
        let americanized = defaults.bool(forKey: "isZmanimAmericanized")
        return hebrew ? "שבת/חג" : americanized ? "Shabbat/Chag" : "Shabbat/Ḥag"
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
                                Text(viewModel.replaceWithDisplayName(zmanName: zman))
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
