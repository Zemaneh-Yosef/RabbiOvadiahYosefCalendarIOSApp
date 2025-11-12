//
//  ZmanimSettingsView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/24/25.
//

import SwiftUI

struct ZmanimSettingsView: View {
    private static let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? .standard
    
    @State private var showCandleLightingAlert = false
    @State private var showTekufaOpinionAlert = false
    @State private var showShabbatEndMinutesAlert = false
    @State private var showEndShabbatOpinionAlert = false

    @AppStorage("LuachAmudeiHoraah", store: defaults) private var amudeiHoraahMode = false
    @AppStorage("overrideAHEndShabbatTime", store: defaults) private var overrideShabbatTime = false
    @AppStorage("overrideRTZman", store: defaults) private var alwaysCalcTenthOfDay = false
    @AppStorage("candleLightingOffset", store: defaults) private var candleLightingOffset = 20
    @AppStorage("tekufaOpinion", store: defaults) private var tekufaOpinion = 0
    @AppStorage("shabbatOffset", store: defaults) private var shabbatOffset = 40
    @AppStorage("endOfShabbatOpinion", store: defaults) private var endOfShabbatOpinion = 1
    
    var body: some View {
        Form {
            Section {
                Toggle("Amudei Horaah Mode", isOn: $amudeiHoraahMode)
            } header: {
                VStack {
                    Text("Zemanim Settings").textCase(nil)
                }
            }
            
            Section {
                Button("Tekufa Opinion: \(tekufaOpinionText())") {
                    showTekufaOpinionAlert = true
                }
            } header: {
                VStack {
                    Text("Tekufa Settings").textCase(nil)
                }
            }
            
            Section {
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
            } header: {
                VStack {
                    Text("Shabbat/Chag Settings").textCase(nil)
                }
            }
            
            Section {
                Toggle("Always use a 10th of the day for Rabbenu Tam", isOn: $alwaysCalcTenthOfDay)
                
                Button("Candle Lighting Time: \(candleLightingOffset) min before sunset") {
                    showCandleLightingAlert = true
                }
            } header: {
                VStack {
                    Text("Other Settings").textCase(nil)
                }
            }
        }
        .navigationTitle("Zemanim Settings")
        
        .alert("Set Candle Lighting Minutes", isPresented: $showCandleLightingAlert) {
            TextField("Minutes", value: $candleLightingOffset, format: .number)
                .keyboardType(.numberPad)
            Button("Save", role: .cancel) { }
        }
        
        .confirmationDialog("Choose Tekufa Opinion", isPresented: $showTekufaOpinionAlert, titleVisibility: .visible) {
            Button("12PM start time (Ohr Hachaim)") { tekufaOpinion = 1 }
            Button("11:39AM start time (Amudei Horaah)") { tekufaOpinion = 2 }
            Button("Show Both") { tekufaOpinion = 3 }
            Button("Calendar Based") { tekufaOpinion = 0 }
        }
        
        .alert("Set Minutes till Shabbat Ends", isPresented: $showShabbatEndMinutesAlert) {
            TextField("Minutes", value: $shabbatOffset, format: .number)
                .keyboardType(.numberPad)
            Button("Save", role: .cancel) { }
        }
        
        .confirmationDialog("Choose End Shabbat Opinion", isPresented: $showEndShabbatOpinionAlert, titleVisibility: .visible) {
            Button("Regular Minutes") { endOfShabbatOpinion = 1 }
            Button("7.165 Degrees") { endOfShabbatOpinion = 2 }
            Button("Lesser of the two") { endOfShabbatOpinion = 3 }
        }
    }
    
    private func tekufaOpinionText() -> String {
        switch tekufaOpinion {
        case 1: return "12PM (Ohr Hachaim)".localized()
        case 2: return "11:39AM (Amudei Horaah)".localized()
        case 3: return "Show Both".localized()
        default: return "Calendar Based".localized()
        }
    }
    
    private func endShabbatOpinionText() -> String {
        switch endOfShabbatOpinion {
        case 1: return "Regular Minutes".localized()
        case 2: return "7.165 Degrees".localized()
        case 3: return "Lesser of the two".localized()
        default: return "Calendar Based".localized()
        }
    }
}


#Preview {
    ZmanimSettingsView()
}
