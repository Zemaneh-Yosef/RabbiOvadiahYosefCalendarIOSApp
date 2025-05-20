//
//  SimpleSetupView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/8/25.
//

import SwiftUI
import KosherSwift

struct SimpleSetupView: View {
    @State private var selectedCountryIndex: Int?
    @State private var selectedState: String = ""
    @State private var selectedMetro: String = ""
    @State private var states: [String] = []
    @State private var metros: [String] = []
    @State private var showStatePicker = false
    @State private var buttonTitle = "Download"
    @State private var buttonColors = [Color("Gold"), Color("GoldStart"), Color("Gold")]
    @State private var isDownloading = false

    private let chaitables = ChaiTablesLinkGenerator()
    private let countries = ChaiTablesCountries.allCases
    private let locationName = GlobalStruct.geoLocation.locationName

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                
                Spacer()
                
                Text(locationName)
                    .font(.headline)
                
                // Country Menu
                Menu {
                    ForEach(countries.indices, id: \.self) { index in
                        Button(countries[index].label) {
                            selectedCountryIndex = index
                            selectedState = ""
                            selectedMetro = ""
                            metros = chaitables.selectCountry(country: countries[index]).reversed()
                            if countries[index] == .USA || countries[index] == .CANADA {
                                showStatePicker = true
                                states = Array(Set(metros.map { String($0.suffix(2)) })).sorted().reversed()
                            } else {
                                showStatePicker = false
                                states = []
                                if metros.count == 1 {
                                    selectedMetro = metros[0]
                                    chaitables.selectMetropolitanArea(metropolitanArea: metros[0])
                                }
                            }
                        }
                    }
                } label: {
                    menuLabel(title: "Select Country", value: selectedCountryIndex.map { countries[$0].label } ?? "")
                }
                .onChange(of: selectedCountryIndex) { newValue in
                    resetButton()
                }
                .onChange(of: selectedState) { newValue in
                    resetButton()
                }
                .onChange(of: selectedMetro) { newValue in
                    resetButton()
                }
                
                // State Menu
                if showStatePicker {
                    Menu {
                        ForEach(states, id: \.self) { state in
                            Button(state) {
                                selectedState = state
                                selectedMetro = ""
                                metros = ChaiTablesLinkGenerator()
                                    .selectCountry(country: countries[selectedCountryIndex ?? 0])
                                    .filter { $0.contains(state) }.reversed()
                                if metros.count == 1 {
                                    selectedMetro = metros[0]
                                    chaitables.selectMetropolitanArea(metropolitanArea: metros[0])
                                }
                            }
                        }
                    } label: {
                        menuLabel(title: "Select State", value: selectedState)
                    }
                }
                
                // Metro Menu
                Menu {
                    ForEach(metros, id: \.self) { metro in
                        Button(metro) {
                            selectedMetro = metro
                            chaitables.selectMetropolitanArea(metropolitanArea: metro)
                        }
                    }
                } label: {
                    menuLabel(title: "Select Metro Area", value: selectedMetro)
                }
                
                Divider()
                
                Button(action: {
                    Task { await downloadTapped() }
                }) {
                    Text(buttonTitle)
                        .foregroundStyle(.black)
                        .font(.title.bold())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: buttonColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .disabled(isDownloading)
                
                Spacer()
            }
            .padding()
            .animation(.easeInOut, value: showStatePicker)
            if isDownloading {
                Color.black.opacity(0.25)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxWidth: .infinity)
                ProgressView("Downloading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundStyle(.white)
            }
        }
    }

    // Label styling for Menu dropdowns
    private func menuLabel(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title.localized())
                .font(.caption)
                .foregroundStyle(.gray)
            Text(value.isEmpty ? "—" : value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }

    private func downloadTapped() async {
        guard let _ = selectedCountryIndex, !selectedMetro.isEmpty else {
            showError()
            return
        }

        isDownloading = true

        let year1 = JewishCalendar().getJewishYear()
        let year2 = year1 + 1
        let lat = GlobalStruct.geoLocation.latitude
        let long = GlobalStruct.geoLocation.longitude
        let tz = -5

        let link1 = chaitables.getChaiTablesLink(lat: lat, long: long, timezone: tz, searchRadius: 8, type: 0, year: year1, userId: 10000)
        let link2 = chaitables.getChaiTablesLink(lat: lat, long: long, timezone: tz, searchRadius: 8, type: 0, year: year2, userId: 10000)

        let scraper = ChaiTablesScraper(
            link: link1,
            locationName: GlobalStruct.geoLocation.locationName,
            jewishYear: year1,
            defaults: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? .standard
        )

        scraper.scrape {
            if scraper.errored {
                showError()
                isDownloading = false
            } else {
                scraper.jewishYear = year2
                scraper.link = link2
                scraper.scrape {
                    isDownloading = false
                    goBackToRootView()
                }
            }
        }
    }
    
    private func resetButton() {
        buttonTitle = "Download".localized()
        buttonColors = [Color("Gold"), Color("GoldStart"), Color("Gold")]
    }

    private func showError() {
        buttonTitle = "Error, did you choose the right location?".localized()
        buttonColors = [.red, .red, .red]
    }
    
    private func goBackToRootView() {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
          return
        }
        guard let firstWindow = firstScene.windows.first else {
          return
        }
        firstWindow.rootViewController = UIHostingController(rootView: ContentView())
        firstWindow.makeKeyAndVisible()
    }
}


#Preview {
    SimpleSetupView()
}
