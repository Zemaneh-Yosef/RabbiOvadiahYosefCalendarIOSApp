//
//  LimudimView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/7/25.
//

import SwiftUI
import KosherSwift
import SwiftyJSON

struct LimudimView: View {
    @State var limudim: [ZmanListEntry] = []
    @State var hiloulot: [ZmanListEntry] = []
    
    @State var userChosenDate: Date = GlobalStruct.userChosenDate
    @State var datePickerIsVisible = false
    @State var hebrewDatePickerIsVisible = false
    
    @State private var selectedLimud: ZmanListEntry? // Track selected item
    @State private var selectedHiloula: ZmanListEntry? // Track selected item
    @State private var showLimudAlert = false
    @State private var showHillulotAlert = false
    @State private var isNasiYomi = false
    @State private var seeMore = false
    
    func syncCalendarDates() {//with userChosenDate
        GlobalStruct.jewishCalendar.workingDate = userChosenDate
        GlobalStruct.userChosenDate = userChosenDate
        updateLimudim()
        updateHillulot()
    }
    
    func limudTitle() -> String {
        if isNasiYomi {
            return selectedLimud?.title.replacingOccurrences(of: "Daily Nasi: ".localized(), with: "") ?? ""
        }
        return "Open Sefaria Link for: ".localized()
            .appending(selectedLimud?.title ?? "")
            .replacingOccurrences(of: "Daf Yomi: ".localized(), with: "")
            .replacingOccurrences(of: "Yerushalmi Vilna Yomi: ".localized(), with: "")
            .replacingOccurrences(of: "Mishna Yomi: ".localized(), with: "")
            .replacingOccurrences(of: "Halacha Yomi: ".localized(), with: "")
            .appending("?")
    }
    
    func updateLimudim() {
        limudim = []
        let hebrewDateFormatter = HebrewDateFormatter()
        hebrewDateFormatter.hebrewFormat = true
        hebrewDateFormatter.useGershGershayim = false
        let dafYomi = GlobalStruct.jewishCalendar.getDafYomiBavli()
        if dafYomi != nil {
            limudim.append(ZmanListEntry(title:"Daf Yomi: ".localized() + hebrewDateFormatter.formatDafYomiBavli(daf: dafYomi!)))
        }
        let yerushalmiYomi = YerushalmiYomiCalculator.getDafYomiYerushalmi(jewishCalendar: GlobalStruct.jewishCalendar)
        if yerushalmiYomi != nil {
            limudim.append(ZmanListEntry(title:"Yerushalmi Vilna Yomi: ".localized() + hebrewDateFormatter.formatDafYomiYerushalmi(daf: yerushalmiYomi)))
        } else {
            limudim.append(ZmanListEntry(title:"No Yerushalmi Vilna Yomi".localized()))
        }
        let mishnaYomi = MishnaYomi().getMishnaYomi(jewishCalendar: GlobalStruct.jewishCalendar, useHebrewText: true)
        if mishnaYomi != nil {
            limudim.append(ZmanListEntry(title: "Mishna Yomi: ".localized() + (mishnaYomi ?? "")))
        }
        
        let halachaSegments = HalachaYomi.getDailyLearning(date: userChosenDate)
        if halachaSegments != nil {
            var halacha = halachaSegments![0].bookName.appending(" ")
            for segment in halachaSegments! {
                halacha = halacha.appending(hebrewDateFormatter.formatHebrewNumber(number: segment.siman)
                    .appending(" ")
                    .appending(segment.seifim)
                    .appending(", "))
            }
            let endIndex = halacha.index(before: halacha.endIndex)
            let endIndex2 = halacha.index(before: endIndex)
            // remove last two characters
            limudim.append(ZmanListEntry(title: "Halacha Yomi: ".localized() + String(halacha[..<endIndex2])))
        }
        
        if !seeMore {
            return
        }
        
        limudim.append(ZmanListEntry(title: "Daily Chafetz Chaim: ".localized() + ChafetzChayimYomi.getChafetzChayimYomi(jewishCalendar: GlobalStruct.jewishCalendar)))
        
        var dailyMonthlyTehilim: Array<String>
        if (Locale.isHebrewLocale()) {
            dailyMonthlyTehilim = [
                "א - ט",       // 1 - 9
                "י - יז",      // 10 - 17
                "יח - כב",     // 18 - 22
                "כג - כח",     // 23 - 28
                "כט - לד",     // 29 - 34
                "לה - לח",     // 35 - 38
                "לט - מג",     // 39 - 43
                "מד - מח",     // 44 - 48
                "מט - נד",     // 49 - 54
                "נה - נט",     // 55 - 59
                "ס - סה",      // 60 - 65
                "סו - סח",     // 66 - 68
                "סט - עא",     // 69 - 71
                "עב - עו",     // 72 - 76
                "עז - עח",     // 77 - 78
                "עט - פב",     // 79 - 82
                "פג - פז",     // 83 - 87
                "פח - פט",     // 88 - 89
                "צ - צו",      // 90 - 96
                "צז - קג",     // 97 - 103
                "קד - קה",     // 104 - 105
                "קו - קז",     // 106 - 107
                "קח - קיב",    // 108 - 112
                "קיג - קיח",   // 113 - 118
                "קיט:א - קיט:צו", // 119:1 - 119:96
                "קיט:צז - קיט:קעו", // 119:97 - 119:176
                "קכ - קלד",     // 120 - 134
                "קל - קלט",     // 135 - 139
                "קמ - " + (GlobalStruct.jewishCalendar.getDaysInJewishMonth() == 29 ? "קנ" : "קמה"), // 140 - 150 or 145
                "קמה - קנ"       // 145 - 150
            ]
        } else {
            dailyMonthlyTehilim = [
                "1 - 9",
                "10 - 17",
                "18 - 22",
                "23 - 28",
                "29 - 34",
                "35 - 38",
                "39 - 43",
                "44 - 48",
                "49 - 54",
                "55 - 59",
                "60 - 65",
                "66 - 68",
                "69 - 71",
                "72 - 76",
                "77 - 78",
                "79 - 82",
                "83 - 87",
                "88 - 89",
                "90 - 96",
                "97 - 103",
                "104 - 105",
                "106 - 107",
                "108 - 112",
                "113 - 118",
                "119:1 - 119:96",
                "119:97 - 119:176",
                "120 - 134",
                "135 - 139",
                "140 - " + (GlobalStruct.jewishCalendar.getDaysInJewishMonth() == 29 ? String(150) : String(145)),
                "145 - 150"]
        }
        limudim.append(ZmanListEntry(title: "Daily Tehilim ".localized() + "(Monthly)".localized() + ": " + dailyMonthlyTehilim[GlobalStruct.jewishCalendar.getJewishDayOfMonth() - 1]))
        
        var dailyWeeklyTehilim: Array<String>
        if (Locale.isHebrewLocale()) {
            dailyWeeklyTehilim = [
                "א - כט",      // 1 - 29
                "ל - נ",       // 30 - 50
                "נא - עב",     // 51 - 72
                "עג - פט",     // 73 - 89
                "צ - קו",      // 90 - 106
                "קז - קיט",    // 107 - 119
                "קכ - קנ"      // 120 - 150
            ]
        } else {
            dailyWeeklyTehilim = [
                "1 - 29",
                "30 - 50",
                "51 - 72",
                "73 - 89",
                "90 - 106",
                "107 - 119",
                "120 - 150"
            ]
        }
        limudim.append(ZmanListEntry(title: "Daily Tehilim ".localized() + "(Weekly)".localized() + ": " + dailyWeeklyTehilim[GlobalStruct.jewishCalendar.getDayOfWeek() - 1]))
        
        let dailyMishnehTorah = DailyMishnehTorah.getDailyLearning(date: userChosenDate)
        if dailyMishnehTorah != nil {
            limudim.append(ZmanListEntry(title: "Rambam Yomi: ".localized()
                .appending(dailyMishnehTorah!.bookName)
                .appending(" ")
                .appending(dailyMishnehTorah!.chapter)))
        }
        let dailyMishnehTorah3 = DailyMishnehTorah.getDailyLearning3(date: userChosenDate)
        if dailyMishnehTorah3 != nil {
            var rambam3Learnings = ""
            for reading in dailyMishnehTorah3! {
                rambam3Learnings = rambam3Learnings
                    .appending(reading.bookName)
                    .appending(" ")
                    .appending(reading.chapter)
                    .appending("\n")
            }
            let endIndex = rambam3Learnings.index(before: rambam3Learnings.endIndex)
            // remove last \n character
            limudim.append(ZmanListEntry(title: "Rambam Yomi 3 Chapters: ".localized().appending("\n").appending(String(rambam3Learnings[..<endIndex]))))
        }
        
        if (GlobalStruct.jewishCalendar.getJewishMonth() == JewishCalendar.NISSAN) {
            let title = NisanLimudYomi.getNisanLimudYomiTitle(day: GlobalStruct.jewishCalendar.getJewishDayOfMonth());
            let reading = NisanLimudYomi.getNisanLimudYomiReading(day: GlobalStruct.jewishCalendar.getJewishDayOfMonth());
            
            if (!title.isEmpty) {
                limudim.append(ZmanListEntry(title: "Daily Nasi: ".localized() + title, desc: reading));
            }
        }
    }
    
    // Method to load JSON from the file and decode it into a Swift object
    func updateHillulot() {
        hiloulot = []
        // Get the file path for the JSON file
        if let path = Bundle.main.path(forResource: Locale.isHebrewLocale() ? "hiloulah_he" : "hiloulah_en", ofType: "json") {
            do {
                // Read the JSON file as Data
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                
                // Parse the data using SwiftyJSON
                let json = try JSON(data: data)
                
                let month = GlobalStruct.jewishCalendar.getNissanStartingJewishMonth()
                let day = GlobalStruct.jewishCalendar.getJewishDayOfMonth()
                var currentDate:String
                if month <= 9 {
                    currentDate = "0" + String(month)
                } else {
                    currentDate = String(month)
                }
                if day <= 9 {
                    currentDate += "0" + String(day)
                } else {
                    currentDate += String(day)
                }
                // Retrieve the array from the JSON for the currentDate
                if let currentHillulot = json[currentDate].array {
                    
                    // Loop through the array of hillulot
                    for hillula in currentHillulot {
                        var entry = ZmanListEntry(title: "")
                        if let name = hillula["name"].string {
                            entry.title = name
                        }
                        
                        if let src = hillula["desc"].string {
                            entry.desc = src
                        }
                        
                        if let src = hillula["src"].string {
                            entry.src = src
                        }
                        hiloulot.append(entry)
                    }
                }
            } catch {
                print("Error reading or parsing the hillulot JSON file: \(error)")
            }
        }
    }
    
    func alerts(view: any View) -> some View {
        let result = view.overlay {
            ZStack {
                if datePickerIsVisible {
                    VStack {
                        DatePicker("", selection: $userChosenDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .onChange(of: userChosenDate) { newValue in
                                syncCalendarDates()
                            }
                        HStack {
                            Button {
                                datePickerIsVisible.toggle()
                                hebrewDatePickerIsVisible.toggle()
                            } label: {
                                Text("Change Calendar")
                            }
                            Spacer()
                            Button {
                                datePickerIsVisible.toggle()
                            } label: {
                                Text("Done")
                            }
                        }.padding()
                    }.frame(width: 320)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .foregroundColor(Color(UIColor.secondarySystemBackground))
                                .shadow(radius: 1)
                        }
                }
                if hebrewDatePickerIsVisible {
                    VStack {
                        DatePicker("", selection: $userChosenDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .environment(\.locale, Locale(identifier: "he"))
                            .environment(\.calendar, Calendar(identifier: .hebrew))
                            .onChange(of: userChosenDate) { newValue in
                                syncCalendarDates()
                            }
                        HStack {
                            Button {
                                hebrewDatePickerIsVisible.toggle()
                                datePickerIsVisible.toggle()
                            } label: {
                                Text("Change Calendar")
                            }
                            Spacer()
                            Button {
                                hebrewDatePickerIsVisible.toggle()
                            } label: {
                                Text("Done")
                            }
                        }.padding()
                    }.frame(width: 320)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .foregroundColor(Color(UIColor.secondarySystemBackground))
                                .shadow(radius: 1)
                        }
                }
            }
        }
        return AnyView(result)
    }
    
    private func centeredButton(title: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text("").frame(maxWidth: 0)
            Spacer()
            Button(title, action: action)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
    }
    
    fileprivate func mainLimudList() -> some View {
        return List {
            Section {
                Text(getDateString(currentDate: userChosenDate))
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onTapGesture {
                        datePickerIsVisible.toggle()
                    }
            }
            
            Section(header: Label("Limudim", systemImage: "book")) {
                if limudim.isEmpty {
                    Text("No limudim available")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                ForEach(limudim.indices, id: \.self) { index in
                    let limud = limudim[index]

                    centeredButton(title: limud.title) {
                        selectedLimud = limud
                        showLimudAlert = shouldShowAlert(title: limud.title)
                        isNasiYomi = limud.title.contains("Daily Nasi: ".localized())
                    }
                    .lineLimit(limud.title.contains("Rambam Yomi 3 Chapters: ".localized()) ? 4 : 1)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                }

                if !seeMore && limudim.count >= 4 {
                    centeredButton(title: "See more...") {
                        seeMore = true
                        updateLimudim()
                    }
                }
            }
            .alert(limudTitle(), isPresented: $showLimudAlert) {
                if !isNasiYomi {
                    Button("OK") {
                        openSefariaLink(selectedLimud: selectedLimud)
                    }
                }
                Button("Dismiss", role: .cancel) {
                    isNasiYomi = false
                }
            } message: {
                if isNasiYomi {
                    Text(selectedLimud?.desc ?? "")
                } else {
                    Text("This will open the Sefaria website or app in a new window.")
                }
            }
            .textCase(nil)

            // Hillulot
            Section(header: Label("Hillulot", systemImage: "flame")) {
                ForEach(hiloulot, id: \.title) { hiloula in
                    HStack {
                        Text("").frame(maxWidth: 0)
                        Spacer()
                        Button(hiloula.title) {
                            selectedHiloula = hiloula
                            showHillulotAlert = true
                        }
                        .font(.title3.bold())
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    }
                }
            }
        }.listStyle(.insetGrouped)
    }
    
    var body: some View {
        alerts(view: mainLimudList())
        .refreshable {
            userChosenDate = Date()
            syncCalendarDates()
        }
        .onAppear {
            userChosenDate = GlobalStruct.userChosenDate
            syncCalendarDates()
        }
        .confirmationDialog(selectedHiloula?.title ?? "", isPresented: $showHillulotAlert, titleVisibility: .visible) {
            Button("Dismiss", role: .cancel) { showHillulotAlert.toggle() }
        } message: {
            Text((selectedHiloula?.desc ?? "").appending("\n-----\n").appending(selectedHiloula?.src ?? ""))
        }.textCase(nil)
        HStack {
            Button {
                userChosenDate = userChosenDate.advanced(by: -86400)
                syncCalendarDates()
            } label: {
                Image(systemName: "arrowtriangle.backward.fill").resizable().scaledToFit().frame(width: 18, height: 18)
            }
            .padding(.leading, 2)
            Spacer()
            Button {
                withAnimation(.easeInOut) {
                    datePickerIsVisible.toggle()
                }
            } label: {
                Image(systemName: "calendar").resizable().scaledToFit().frame(width: 26, height: 26)
            }
            Spacer()
            Button {
                userChosenDate = userChosenDate.advanced(by: 86400)
                syncCalendarDates()
            } label: {
                Image(systemName: "arrowtriangle.forward.fill").resizable().scaledToFit().frame(width: 18, height: 18)
            }
            .padding(.trailing, 2)
        }.padding(.init(top: 2, leading: 0, bottom: 8, trailing: 0))
    }
}

func getDateString(currentDate: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMMM, yyyy"
    dateFormatter.timeZone = GlobalStruct.geoLocation.timeZone
    var date = dateFormatter.string(from: currentDate)

    let hebrewDateFormatter = HebrewDateFormatter().withCorrectEnglishMonths()
    var hebrewDate = hebrewDateFormatter.format(jewishCalendar: GlobalStruct.jewishCalendar)
    if Locale.isHebrewLocale() {
        hebrewDateFormatter.hebrewFormat = true
        hebrewDate = hebrewDateFormatter.format(jewishCalendar: GlobalStruct.jewishCalendar)
    }
    
    if Calendar.current.isDateInToday(currentDate) {
        date += "   ▼   " + hebrewDate
    } else {
        date += "       " + hebrewDate
    }
    return date
}

func shouldShowAlert(title: String) -> Bool {
    if title.contains("Daf Yomi: ".localized()) ||
        title.contains("Yerushalmi Vilna Yomi: ".localized()) ||
        title.contains("Mishna Yomi: ".localized()) ||
        title.contains("Halacha Yomi: ".localized()) ||
        title.contains("Daily Nasi: ".localized()) {
        return true
    } else {
        return false
    }
}

func openSefariaLink(selectedLimud: ZmanListEntry?) {
    if selectedLimud!.title.contains("Daf Yomi: ".localized()) {
        let dafObject = YomiCalculator.getDafYomiBavli(jewishCalendar: GlobalStruct.jewishCalendar)
        if dafObject != nil {
            let masechta = dafObject!.getMasechtaTransliterated()
            let daf = dafObject!.getDaf()
            let dafYomiLink: String = "https://www.sefaria.org/"
                .appending(masechta)
                .appending(".")
                .appending(String(daf))
                .appending("a")
            if let url = URL(string: dafYomiLink) {
                UIApplication.shared.open(url)
            }
        }
    } else if selectedLimud!.title.contains("Yerushalmi Vilna Yomi: ".localized()) {
        let dafYomiYerushalmi = YerushalmiYomiCalculator.getDafYomiYerushalmi(jewishCalendar: GlobalStruct.jewishCalendar)
        let masechtotYerushalmiTransliterated = ["Berakhot", "Peah", "Demai", "Kilayim", "Sheviit",
                                                 "Terumot", "Maasrot", "Maaser Sheni", "Challah", "Orlah", "Bikkurim", "Shabbat", "Eruvin", "Pesachim",
                                                 "Beitzah", "Rosh Hashanah", "Yoma", "Sukkah", "Taanit", "Shekalim", "Megillah", "Chagigah", "Moed Katan",
                                                 "Yevamot", "Ketubot", "Sotah", "Nedarim", "Nazir", "Gittin", "Kiddushin", "Bava Kamma", "Bava Metzia",
                                                 "Bava Batra", "Shevuot", "Makkot", "Sanhedrin", "Avodah Zarah", "Horayot", "Niddah", "No Daf Today"]
        if dafYomiYerushalmi != nil {
            dafYomiYerushalmi!.setYerushalmiMasechtaTransliterated(masechtosYerushalmiTransliterated: masechtotYerushalmiTransliterated)
            let yerushalmiYomiLink = "https://www.sefaria.org/" + "Jerusalem_Talmud_" + (dafYomiYerushalmi!.getYerushalmiMasechtaTransliterated())
            if let url = URL(string: yerushalmiYomiLink) {
                UIApplication.shared.open(url)
            }
        }
    } else if selectedLimud!.title.contains("Mishna Yomi: ".localized()) {
        let mishnaYomi = MishnaYomi(jewishCalendar: GlobalStruct.jewishCalendar, useHebrewText: false)
        if mishnaYomi.getMishnaYomi(jewishCalendar: GlobalStruct.jewishCalendar, useHebrewText: false) != nil {
            let mishnaYomiLink = "https://www.sefaria.org/".appending((mishnaYomi.sFirstMasechta == "Avot" ? "" : "Mishnah_")) // apparently Pirkei Avot link is missing the Mishnah_ part
                .appending(replaceWithSefariaNames(masechta: mishnaYomi.sFirstMasechta))
                .appending(".")
                .appending(String(mishnaYomi.sFirstPerek))
                .appending(".")
                .appending(String(mishnaYomi.sFirstMishna))
            if let url = URL(string: mishnaYomiLink) {
                UIApplication.shared.open(url)
            }
        }
    } else if selectedLimud!.title.contains("Halacha Yomi: ".localized()) {
        let halachaYomi = HalachaYomi.getDailyLearning(date: GlobalStruct.userChosenDate)
        if halachaYomi != nil {
            let halachaYomiLink = "https://www.sefaria.org/".appending((halachaYomi![0].bookName == "שו\"ע - או\"ח" ? "Shulchan_Arukh%2C_Orach_Chayim." : "Kitzur_Shulchan_Arukh."))
                .appending(String(halachaYomi![0].siman))
                .appending(".")
                .appending(String(halachaYomi![0].firstSeif))
            if let url = URL(string: halachaYomiLink) {
                UIApplication.shared.open(url)
            }
        }
    }
}

private func replaceWithSefariaNames(masechta: String) -> String {
    switch (masechta) {
    case "Berachot": return "Berakhot";
    case "Maaser Sheni": return "Maaser_Sheni";
    case "Bikurim": return "Bikkurim";
    case "Rosh Hashanah": return "Rosh_Hashanah";
    case "Taanit": return "Ta'anit";
    case "Moed Katan": return "Moed_Katan";
    case "Avodah Zarah": return "Avodah_Zarah";
    case "Avot": return "Pirkei_Avot";
    case "Horiyot": return "Horayot";
    case "Bechorot": return "Bekhorot";
    case "Arachin": return "Arakhin";
    case "Midot": return "Middot";
    case "Keilim": return "Kelim";
    case "Ohalot": return "Oholot";
    case "Machshirin": return "Makhshirin";
    case "Tevul Yom": return "Tevul_Yom";
    case "Uktzin": return "Oktzin";
    default:
        return masechta; // If no match is found, return the original string
    };
}

#Preview {
    LimudimView()
}
