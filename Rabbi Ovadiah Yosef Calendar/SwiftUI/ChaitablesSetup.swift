//
//  SetupChooserView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/8/25.
//

import SwiftUI
import KosherSwift
import SwiftSoup

struct ChaitablesSetup: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showInfo = false
    @State private var navigateToAdvanced = false

    @State private var selectedCountryIndex: Int?
    @State private var selectedState: String = ""
    @State private var selectedMetro: String = ""
    @State private var states: [String] = []
    @State private var metros: [String] = []
    @State private var showStatePicker = false
    @State private var buttonTitle = "Download".localized()
    @State private var buttonColors = [Color("Gold"), Color("GoldStart"), Color("Gold")]
    @State private var isDownloading = false

    let defaults = UserDefaults.getMyUserDefaults()
    @State private var chaitables = ChaiTablesLinkGenerator()
    private let countries = ChaiTablesCountries.allCases
    private let locationName = GlobalStruct.geoLocation.locationName
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Spacer()
                    
                    Text("והנכון הוא ללכת אחר לוח אור החיים, או לוח ביכורי יוסף, וכדומה, המבוסס על הזריחה המוקדמת ביותר הנראית מעל אופק המזרחי האמיתי, מנקודה כלשהי בישוב, מידי יום ביומו, בסיוע מודל טופוגרפי ממוחשב של ארץ ישראל.")
                        .font(.custom("FrankRuehl", size: 26))
                        .multilineTextAlignment(.center)
                    Text("(ילקוט יוסף מהדורא תשפ״א סימן פ״ט סעיף ג)")
                        .font(.custom("FrankRuehl", size: 20))
                    
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
                                metros = chaitables.selectCountry(country: countries[index]).sorted()
                                if countries[index] == .USA || countries[index] == .CANADA {
                                    showStatePicker = true
                                    states = Array(Set(metros.map { String($0.suffix(2)) })).sorted()
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
                                        .filter { $0.contains(state) }.sorted()
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
                    
                    if isDownloading {
                        Color.black.opacity(0.25)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(maxWidth: .infinity)
                        ProgressView("Downloading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundStyle(.white)
                    }
                    
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
                    NavigationLink(destination: AdvancedSetupView(), isActive: $navigateToAdvanced) { EmptyView() }
                        .animation(.easeInOut, value: showStatePicker)
                }
            }
        }
        .onAppear {
            loadSavedData()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showInfo = true
                    } label: {
                        HStack {
                            Text("Introduction")
                        }
                    }
                    Button {
                        navigateToAdvanced = true
                    } label: {
                        Text("Advanced Setup")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .padding(10)
                        .background(alignment: .center) {
                            Color.gray.opacity(0.2)
                        }
                        .clipShape(Circle())
                }
            }
        }
        .alert("Introduction".localized(), isPresented: $showInfo) {
            Button("Dismiss".localized(), role: .cancel) {}
        } message: {
            Text(infoMessage)
        }
        .navigationTitle("Visible Sunrise Setup")
    }

    var infoMessage: String {
        if Locale.isHebrewLocale() {
            return "הגדרת \"זריחה נראית\" זו תחליף את זמני הזריחה המוצגים באפליקציה בזמנים המקבילים להם מאתר ChaiTables.com ומלוח \"בחורי יוסף\" שבישראל. זמנים אלו מדויקים יותר עבור מי שמתפלל שחרית עם הזריחה, והם בשימוש בלוח אור החיים בישראל.\n\nכל שעליך לספק הוא המדינה והאזור המטרופוליני שלך (ולעיתים תתבקש גם לבחור מדינה-משנה). מנגנון הורדת הטבלאות יאתר תחילה את הרדיוס הקטן ביותר של יישובך, ולאחר מכן יוריד את הטבלאות לשנתיים הקרובות. בשנים הבאות, הטבלה תעשה שימוש במידע שנשמר מהגדרה זו כדי לטעון את הנתונים בצורה חלקה ככל האפשר.\n\nאם ברצונך לציין מידע נוסף (כגון רדיוס מותאם אישית), עליך להשתמש באפשרות \"הגדרה מתקדמת\" — אפשרות זו תאפשר לך להזין קישור מותאם אישית ל-ChaiTables שממנו יבוצע השאיבה. אם אין ברשותך קישור ל-ChaiTables, תוכל לנווט באתר מתוך האפליקציה.\n\nלאחר מכן תישאל האם ברצונך להגדיר נתוני גובה עבור העיר שאליה מוגדרת האפליקציה. יש לדעת שנתוני הגובה משתנים מעיר לעיר, ותידרש להגדיר את נתוני הגובה של עירך בכל פעם שתשנה עיר."
        } else {
            return "This \"Visual Sunrise\" setup will replace our listed sunrise times with their equivalent from the ChaiTables.com website &amp; \"Bechorei Yosef\" calendar in Israel. These times are more accurate for those who pray Shaḥarit by sunrise, and they\'re in use by the Ohr HaChaim calendar in Israel.\n\nAll you need to provide is your country and metro area (with it sometimes asking for a state too). Our table-downloader will first find the smallest radius of your town, and then download the tables for the next two years. For future years, the table will reuse information saved from this setup to load your data as seamlessly as possible.\n\nIf you want to specify more information (such as a custom radius size), you should instead use our \"Advanced Setup\" - this will allow you to specify your own ChaiTables link to scrape from. You could navigate the website in our app if you don\'t have a ChaiTables link.\n\nIt will then ask you if you want to setup elevation for the city the app is set to. Know that the elevation data changes for each and every city and you will need to set the elevation data of your city every time you change cities."
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
    
    func loadSavedData() {
        if defaults.object(forKey: "selectedCountryIndex") != nil {
            selectedCountryIndex = defaults.integer(forKey: "selectedCountryIndex")
        } else {
            return // Nothing saved yet
        }
        
        let selectedEnum = countries[selectedCountryIndex ?? 0]
        
        // 2. Rebuild the metros list
        let allMetros = chaitables.selectCountry(country: selectedEnum).sorted()
        
        // 3. Handle USA/Canada logic
        if selectedEnum == .USA || selectedEnum == .CANADA {
            showStatePicker = true
            states = Array(Set(allMetros.map { String($0.suffix(2)) })).sorted()
            
            // If a state was saved, filter the metros for that state
            selectedState = defaults.string(forKey: "selectedState") ?? ""
            if !selectedState.isEmpty {
                metros = allMetros.filter { $0.contains(selectedState) }.sorted()
            } else {
                metros = allMetros
            }
        } else {
            showStatePicker = false
            metros = allMetros
        }
        
        // 4. If a metro was saved, notify the generator
        selectedMetro = defaults.string(forKey: "selectedMetro") ?? ""
        if !selectedMetro.isEmpty {
            chaitables.selectMetropolitanArea(metropolitanArea: selectedMetro)
        }
    }

    @MainActor
    private func downloadTapped() async {
        guard let _ = selectedCountryIndex, !selectedMetro.isEmpty else {
            showError()
            return
        }

        // Persist selections
        defaults.set(selectedCountryIndex, forKey: "selectedCountryIndex")
        defaults.set(selectedState, forKey: "selectedState")
        defaults.set(selectedMetro, forKey: "selectedMetro")

        isDownloading = true
        defer { isDownloading = false } // defer = run this code any way this method ends

        let geo = GlobalStruct.geoLocation
        let tz = geo.timeZone.secondsFromGMT() / 3600

        let year1 = JewishCalendar().getJewishYear()
        let year2 = year1 + 1

        do {
            // 1. Find smallest valid radius (year 1 only), uses chaitable.getChaiTablesLink
            let best = try await findBestRadius(
                lat: geo.latitude,
                long: geo.longitude,
                tz: tz,
                year: year1
            )
            
            if best.radius.isEmpty {
                showError()
                return
            }

            // 2. Scrape year 1
            let scraper = ChaiTablesScraper(
                link: best.link,
                locationName: geo.locationName,
                jewishYear: year1,
                defaults: defaults
            )

            guard await scraper.scrapeAsync() else {
                showError()
                return
            }

            // 3. Reuse SAME radius for year 2
            scraper.jewishYear = year2
            scraper.link = chaitables.getChaiTablesLink(
                lat: geo.latitude,
                long: geo.longitude,
                timezone: tz,
                searchRadius: Double(best.radius)!,
                type: 0,
                year: year2,
                userId: 10000
            )

            guard await scraper.scrapeAsync() else {
                showError()
                return
            }

            goBackToRootView()

        } catch {
            showError()
        }
    }

    func findZmanTable(in doc: Document) -> Element? {
        do {
            for table in try doc.select("table") {
                guard let firstRow = try table.select("tr").first() else { continue }
                let cellCount = firstRow.children().count
                if cellCount == 14 || cellCount == 15 {
                    return table
                }
            }
        } catch {
            return nil
        }
        return nil
    }
    
    func containsNoVantagePointMessage(in doc: Document) -> Bool {
        let text = (try? doc.text()) ?? ""
        return text.contains("Couldn't find a vantage point within the chosen search radius")
    }

    func fetchDocument(from urlString: String) async throws -> Document {
        guard let url = URL(string: urlString) else {
            print("Bad URL")
            return Document("")
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(decoding: data, as: UTF8.self)
        return try SwiftSoup.parse(html)
    }

    func findBestRadius(lat: Double, long: Double, tz: Int, year: Int) async throws -> (radius: String, link: String) {

        for radius in ChaiTablesLinkGenerator.search_radii {

            let link = chaitables.getChaiTablesLink(
                lat: lat,
                long: long,
                timezone: tz,
                searchRadius: Double(radius)!,
                type: 0,
                year: year,
                userId: 10000
            )
            
            print("Radius: \(radius) URL: \(link)")

            let doc = try await fetchDocument(from: link)

            // Success case
            if findZmanTable(in: doc) != nil {
                return (radius, link)
            }

            // Explicit failure → try next radius
            if containsNoVantagePointMessage(in: doc) {
                continue
            }
        }

        return ("", "")
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

// MARK: - Styles

struct FilledButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct PlainButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 2))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

#Preview {
    ChaitablesSetup()
}

