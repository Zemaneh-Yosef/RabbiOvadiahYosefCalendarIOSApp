//
//  ZmanimSettingsView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/24/25.
//

import SwiftUI

@available(iOS 15.0, *)
struct ZmanimSettingsView: View {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? .standard
    
    @State private var showCandleLightingAlert = false
    @State private var showTekufaOpinionAlert = false
    @State private var showShabbatEndMinutesAlert = false
    @State private var showEndShabbatOpinionAlert = false

    @AppStorage("LuachAmudeiHoraah", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var amudeiHoraahMode = false
    @AppStorage("overrideAHEndShabbatTime", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var overrideShabbatTime = false
    @AppStorage("overrideRTZman", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var alwaysCalcTenthOfDay = false
    @AppStorage("candleLightingOffset", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var candleLightingOffset = 20
    @AppStorage("tekufaOpinion", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var tekufaOpinion = 0
    @AppStorage("shabbatOffset", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var shabbatOffset = 40
    @AppStorage("endOfShabbatOpinion", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var endOfShabbatOpinion = 1
    
    var body: some View {
        Form {
            Section(header: Text("Zmanim Settings")) {
                Toggle("Amudei Horaah Mode", isOn: $amudeiHoraahMode)
            }
            
            Section(header: Text("Tekufa Settings")) {
                Button("Tekufa Opinion: \(tekufaOpinionText())") {
                    showTekufaOpinionAlert = true
                }
            }
            
            Section(header: Text("Shabbat/Chag Settings")) {
                Toggle("Override the time for Shabbat End", isOn: $overrideShabbatTime)
                
                Button("Minutes till Shabbat Ends: \(shabbatOffset)") {
                    if overrideShabbatTime {
                        showShabbatEndMinutesAlert = true
                    }
                }
                .disabled(!overrideShabbatTime)
                
                Button("End Shabbat Opinion: \(endShabbatOpinionText())") {
                    if overrideShabbatTime {
                        showEndShabbatOpinionAlert = true
                    }
                }
                .disabled(!overrideShabbatTime)
            }
            
            Section(header: Text("Other Settings")) {
                Toggle("Always use a 10th of the day for Rabbeinu Tam", isOn: $alwaysCalcTenthOfDay)
                
                Button("Candle Lighting Time: \(candleLightingOffset) min before sunset") {
                    showCandleLightingAlert = true
                }
            }
        }
        .navigationTitle("Zmanim Settings")
        
        .alert("Set Candle Lighting Minutes", isPresented: $showCandleLightingAlert) {
            TextField("Minutes", value: $candleLightingOffset, format: .number)
                .keyboardType(.numberPad)
            Button("Save", role: .cancel) { }
        }
        
        .confirmationDialog("Choose Tekufa Opinion", isPresented: $showTekufaOpinionAlert, titleVisibility: .visible) {
            Button("12PM start time (Ohr Hachaim)") { tekufaOpinion = 1 }
            Button("11:39AM start time (Amudei Horaah)") { tekufaOpinion = 2 }
            Button("Show Both") { tekufaOpinion = 3 }
        }
        
        .alert("Set Minutes till Shabbat Ends", isPresented: $showShabbatEndMinutesAlert) {
            TextField("Minutes", value: $shabbatOffset, format: .number)
                .keyboardType(.numberPad)
            Button("Save", role: .cancel) { }
        }
        
        .confirmationDialog("Choose End Shabbat Opinion", isPresented: $showEndShabbatOpinionAlert, titleVisibility: .visible) {
            Button("Regular Minutes") { endOfShabbatOpinion = 1 }
            Button("7.14 Degrees") { endOfShabbatOpinion = 2 }
            Button("Lesser of the two") { endOfShabbatOpinion = 3 }
        }
    }
    
    private func tekufaOpinionText() -> String {
        switch tekufaOpinion {
        case 1: return "12PM (Ohr Hachaim)"
        case 2: return "11:39AM (Amudei Horaah)"
        case 3: return "Show Both"
        default: return "Calendar Based"
        }
    }
    
    private func endShabbatOpinionText() -> String {
        switch endOfShabbatOpinion {
        case 1: return "Regular Minutes"
        case 2: return "7.14 Degrees"
        case 3: return "Lesser of the two"
        default: return "Calendar Based"
        }
    }
}


#Preview {
    if #available(iOS 15.0, *) {
        ZmanimSettingsView()
    } else {
        // Fallback on earlier versions
    }
}
