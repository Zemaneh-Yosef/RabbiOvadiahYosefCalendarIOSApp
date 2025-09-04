//
//  SiddurChooserView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 4/7/25.
//

import SwiftUI
import KosherSwift
import SwiftUISnackbar

struct SiddurChooserView: View {
    @State private var siddurPrayer = "" {
        didSet {
            GlobalStruct.chosenPrayer = siddurPrayer
        }
    }
    @State private var showSiddur = false
    
    @State var userChosenDate: Date = GlobalStruct.userChosenDate
    @State var showAllPrayers = false // if false, show only the currently available prayers
    @State var adjustDateBasedOnSunset = true
    @State var lastTimeUserWasInApp = Date()
    @State var datePickerIsVisible = false
    @State var hebrewDatePickerIsVisible = false
    
    @State var showBirchatHamazonAlert = false
    @State var showMeEyinShaloshChoicePicker = false
    @State var showMeEyinShaloshAlert = false
    let choices = [
        "Wine".localized(),
        "5 Grains".localized(),
        "Olives, dates, grapes, figs and/or pomegranates".localized(),
        "Other".localized()
    ]
    @State private var selectedChoices: [String] = []
    @State var showTikkunChatzotDayOptionAlert = false
    @State var showTikkunChatzotNotSaidTodayAlert = false
    @State var showTikkunChatzotNotSaidTodayOrTonightAlert = false
    @State var showTikkunChatzotNotSaidTonightAlert = false
    @State var showMukafChomaAlert = false
    @State var showHavdalaAlert = false
    @State var showSelectSomethingSnackbar = false
    @State private var showMasechtaPicker = false
    @State private var selectedMasechtot: [String] = []
    @State private var masechtot = [
        "ברכות",
        "שבת",
        "עירובין",
        "פסחים",
        "שקלים",
        "יומא",
        "סוכה",
        "ביצה",
        "ראש השנה",
        "תענית",
        "מגילה",
        "מועד קטן",
        "חגיגה",
        "יבמות",
        "כתובות",
        "נדרים",
        "נזיר",
        "סוטה",
        "גיטין",
        "קידושין",
        "בבא קמא",
        "בבא מציעא",
        "בבא בתרא",
        "סנהדרין",
        "מכות",
        "שבועות",
        "עבודה זרה",
        "הוריות",
        "זבחים",
        "מנחות",
        "חולין",
        "בכורות",
        "ערכין",
        "תמורה",
        "כריתות",
        "מעילה",
        "קינים",
        "תמיד",
        "מידות",
        "נדה"
    ]
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    let secondaryTextSize = Font.system(size: 14)
    
    private func getSunsetBasedJewishCalendar(_ adjust: Bool = true) -> JewishCalendar {
        var result = GlobalStruct.jewishCalendar
        if !showAllPrayers {
            result = JewishCalendar(workingDate: Date(), timezone: .autoupdatingCurrent, inIsrael: GlobalStruct.jewishCalendar.inIsrael, useModernHolidays: true)
            let currentZmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
            currentZmanimCalendar.useElevation = GlobalStruct.useElevation
            if (currentZmanimCalendar.getElevationAdjustedSunset() ?? Date() < Date() && adjust && adjustDateBasedOnSunset) {
                result.forward()
            }
        }
        return result
    }
        
    func syncCalendarDates() {//with userChosenDate
        GlobalStruct.jewishCalendar.workingDate = userChosenDate
        GlobalStruct.userChosenDate = userChosenDate
        autoFillMasechta()
    }
    
    var selichotButton: some View {
        Button(action: {
            siddurPrayer = "Selichot"
            openSiddurView()
        }) {
            VStack(alignment: .leading) {
                Text("סליחות")
                    .foregroundColor(shouldBeDimmed("סליחות") ? .gray : .primary)
                if let secondary = getSecondaryText("סליחות") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var shacharitButton: some View {
        Button(action: {
            siddurPrayer = "Shacharit"
            openSiddurView()
        }) {
            VStack(alignment: .leading) {
                Text("שחרית")
                if let secondary = getSecondaryText("שחרית") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var mussafButton: some View {
        Button(action: {
            siddurPrayer = "Mussaf"
            openSiddurView()
        }) {
            VStack(alignment: .leading) {
                Text("מוסף")
                if let secondary = getSecondaryText("מוסף") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }

    var minchaButton: some View {
        Button(action: {
            siddurPrayer = "Mincha"
            openSiddurView()
        }) {
            VStack(alignment: .leading) {
                Text("מנחה")
                if let secondary = getSecondaryText("מנחה") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var arvitButton: some View {
        Button(action: {
            if showAllPrayers {
                siddurPrayer = "Arvit+1"
            } else {
                siddurPrayer = "Arvit"
            }
            openSiddurView()
        }) {
            VStack(alignment: .leading) {
                Text("ערבית")
                if let secondary = getSecondaryText("ערבית") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var sefiratHaomerButton: some View {
        Button(action: {
            if showAllPrayers {
                siddurPrayer = "Sefirat HaOmer+1"
            } else {
                siddurPrayer = "Sefirat HaOmer"
            }
            openSiddurView()
        }) {
            VStack(alignment: .leading) {
                Text("ספירת העומר")
                if let secondary = getSecondaryText("ספירת העומר") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var hadlaketNeirotChanukaButton: some View {
        Button(action: {
            siddurPrayer = "Hadlakat Neirot Chanuka"
            openSiddurView()
        }) {
            VStack(alignment: .leading) {
                Text("הדלקת נרות חנוכה")
                if let secondary = getSecondaryText("הדלקת נרות חנוכה") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var havdalaButton: some View {
        Button(action: {
            if (showAllPrayers && getSunsetBasedJewishCalendar().tomorrow().isTishaBav() && GlobalStruct.jewishCalendar.getDayOfWeek() == 7) {
                showHavdalaAlert = true
            } else {
                if (!showAllPrayers && getSunsetBasedJewishCalendar().isTishaBav() && getSunsetBasedJewishCalendar().getDayOfWeek() == 1) {
                    showHavdalaAlert = true
                } else {
                    if showAllPrayers {
                        siddurPrayer = "Havdala+1"
                    } else {
                        siddurPrayer = "Havdala"
                    }
                    openSiddurView()
                }
            }
        }) {
            VStack(alignment: .leading) {
                Text("הבדלה")
                    .foregroundColor(shouldBeDimmed("הבדלה") ? .gray : .primary)
                if let secondary = getSecondaryText("הבדלה") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var kriatShemaButton: some View {
        Button(action: {
            if showAllPrayers {
                siddurPrayer = "Kriat Shema SheAl Hamita+1"
            } else {
                siddurPrayer = "Kriat Shema SheAl Hamita"
            }
            openSiddurView()
        }) {
            VStack(alignment: .leading) {
                Text("ק״ש שעל המיטה")
                if let secondary = getSecondaryText("ק״ש שעל המיטה") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var tikkunChatzotButton: some View {
        Button(action: {
            handleTikkunChatzot()
        }) {
            VStack(alignment: .leading) {
                Text("תיקון חצות")
                    .foregroundColor(shouldBeDimmed("תיקון חצות") ? .gray : .primary)
                if let secondary = getSecondaryText("תיקון חצות (לילה)") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var tikkunChatzot3WeeksButton: some View {
        Button(action: {
            handleTikkunChatzot()
        }) {
            VStack(alignment: .leading) {
                Text("תיקון חצות")
                    .foregroundColor(shouldBeDimmed("תיקון חצות") ? .gray : .primary)
                if let secondary = getSecondaryText("תיקון חצות") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var birchatHamazonButton: some View {
        Button(action: {
            siddurPrayer = "Birchat Hamazon"
            handleBirchatHamazon()
        }) {
            VStack(alignment: .leading) {
                Text("ברכת המזון")
                if let secondary = getSecondaryText("ברכת המזון") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var bmsButton: some View {
        Button(action: {
            siddurPrayer = "Birchat MeEyin Shalosh"
            showMeEyinShaloshChoicePicker = true
        }) {
            VStack(alignment: .leading) {
                Text("ברכת מעין שלוש")
                if let secondary = getSecondaryText("ברכת מעין שלוש") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .sheet(isPresented: $showMeEyinShaloshChoicePicker) {
            NavigationView {
                List {
                    ForEach(choices, id: \.self) { choice in
                        Button(action: {
                            if let index = selectedChoices.firstIndex(of: choice) {
                                selectedChoices.remove(at: index)
                            } else {
                                selectedChoices.append(choice)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedChoices.contains(choice) ? "checkmark.square.fill" : "square")
                                Text(choice)
                                Spacer()
                            }
                            .contentShape(Rectangle()) // Makes entire row tappable
                        }
                        .buttonStyle(.plain)
                    }
                }
                .navigationTitle("What did you eat/drink?")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            if selectedChoices.isEmpty {
                                showSelectSomethingSnackbar = true
                            } else {
                                showMeEyinShaloshChoicePicker = false
                                GlobalStruct.meEyinShaloshChoices = selectedChoices.joined(separator: ", ")
                                handleMeEyinShalosh()
                            }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showMeEyinShaloshChoicePicker = false
                        }
                    }
                }
            }
        }
    }
    
    var tefilatHaderechButton: some View {
        Button(action: {
            siddurPrayer = "Tefilat HaDerech"
            openSiddurView()
        }) {
            VStack(alignment: .leading) {
                Text("תפלת הדרך")
                if let secondary = getSecondaryText("תפלת הדרך") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var siyumMasechetButton: some View {
        Button(action: {
            siddurPrayer = "Seder Siyum Masechet"
            showMasechtaPicker = true
        }) {
            VStack(alignment: .leading) {
                Text("סדר סיום מסכת")
                if let secondary = getSecondaryText("סדר סיום מסכת") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .sheet(isPresented: $showMasechtaPicker) {
            NavigationView {
                List {
                    ForEach(masechtot, id: \.self) { masechta in
                        Button(action: {
                            if let index = selectedMasechtot.firstIndex(of: masechta) {
                                selectedMasechtot.remove(at: index)
                            } else {
                                selectedMasechtot.append(masechta)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedMasechtot.contains(masechta) ? "checkmark.square.fill" : "square")
                                Text(masechta)
                                Spacer()
                            }
                            .contentShape(Rectangle()) // Makes entire row tappable
                        }
                        .buttonStyle(.plain)
                    }
                }
                .navigationTitle("Choose Masekhtot")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            if !selectedMasechtot.isEmpty {
                                showMasechtaPicker = false
                                GlobalStruct.siyumChoices = selectedMasechtot
                                openSiddurView()
                            }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showMasechtaPicker = false
                        }
                    }
                }
            }
        }
    }
    
    var birchatHalevanaButton: some View {
        Button(action: {
            siddurPrayer = "Birchat Halevana"
            openSiddurView()
        }) {
            VStack(alignment: .leading) {
                Text("ברכת הלבנה")
                if let secondary = getSecondaryText("ברכת הלבנה") {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var prayerForEtrogButton: some View {
        Button(action: {
            if let openLink = URL(string: "https://elyahu41.github.io/Prayer%20for%20an%20Etrog.pdf") {
                if UIApplication.shared.canOpenURL(openLink) {
                    UIApplication.shared.open(openLink, options: [:])
                }
            }
        }) {
            VStack(alignment: .leading) {
                Text("Prayer for Etrog".localized())
                if let secondary = getSecondaryText("Prayer for Etrog".localized()) {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    var parshatHamanButton: some View {
        Button(action: {
            if let openLink = URL(string: "https://elyahu41.github.io/Parshat-Haman-3.pdf") {
                if UIApplication.shared.canOpenURL(openLink) {
                    UIApplication.shared.open(openLink, options: [:])
                }
            }
        }) {
            VStack(alignment: .leading) {
                Text("Parshat Haman".localized())
                if let secondary = getSecondaryText("Parshat Haman".localized()) {
                    Text(secondary)
                        .font(secondaryTextSize)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    private var mainList: some View {
        List {
            Section {
                if showAllPrayers ? getSunsetBasedJewishCalendar().isSelichotSaid() : getSunsetBasedJewishCalendar().isSelichotSaid() && isPrayerCurrentlySaid(key: "סליחות") {
                    selichotButton
                }
                if showAllPrayers || isPrayerCurrentlySaid(key: "שחרית") {
                    shacharitButton
                }
                if (getSunsetBasedJewishCalendar().isRoshChodesh() || getSunsetBasedJewishCalendar().isCholHamoed())
                    && (showAllPrayers || isPrayerCurrentlySaid(key: "מוסף")) {
                    mussafButton
                }
                if showAllPrayers || isPrayerCurrentlySaid(key: "מנחה") {
                    minchaButton
                }
                if !showAllPrayers {
                    if isPrayerCurrentlySaid(key: "ערבית") {
                        arvitButton
                    }
                    if (getSunsetBasedJewishCalendar().getDayOfOmer() != -1 && getSunsetBasedJewishCalendar().getDayOfOmer() <= 49) && isPrayerCurrentlySaid(key: "ספירת העומר") {
                        sefiratHaomerButton
                    }
                    if isPrayerCurrentlySaid(key: "הדלקת נרות חנוכה") && getSunsetBasedJewishCalendar().isChanukah() {
                        hadlaketNeirotChanukaButton
                    }
                    if (!getSunsetBasedJewishCalendar().yesterday().hasCandleLighting()
                        && getSunsetBasedJewishCalendar().yesterday().isAssurBemelacha()
                        || (getSunsetBasedJewishCalendar().yesterday().isTishaBav()
                            && getSunsetBasedJewishCalendar().getDayOfWeek() == 2))// because after sunset
                        && isPrayerCurrentlySaid(key: "הבדלה") {
                        havdalaButton
                    }
                    if isPrayerCurrentlySaid(key: "ק״ש שעל המיטה") {
                        kriatShemaButton
                    }
                    if isPrayerCurrentlySaid(key: "תיקון חצות (לילה)") {
                        tikkunChatzotButton
                    }
                }
            } header: {
                VStack {
                    Text(getDayTitle(userChosenDate)).textCase(nil)
                }
            }
            .textCase(nil)
            
            if showAllPrayers {// hide night section if we are only showing the current prayers
                Section {
                    arvitButton
                    if !(GlobalStruct.jewishCalendar.tomorrow().getDayOfOmer() == -1 || GlobalStruct.jewishCalendar.getDayOfOmer() >= 49) {
                        sefiratHaomerButton
                    }
                    if (GlobalStruct.jewishCalendar.tomorrow().isChanukah() || GlobalStruct.jewishCalendar.isChanukah() && GlobalStruct.jewishCalendar.getDayOfChanukah() != 8) {
                        hadlaketNeirotChanukaButton
                    }
                    if !GlobalStruct.jewishCalendar.hasCandleLighting() && GlobalStruct.jewishCalendar.isAssurBemelacha() || (GlobalStruct.jewishCalendar.isTishaBav() && (GlobalStruct.jewishCalendar.getDayOfWeek() == 7 || GlobalStruct.jewishCalendar.getDayOfWeek() == 1)) {
                        havdalaButton
                    }
                    kriatShemaButton
                    if !getSunsetBasedJewishCalendar(false).is3Weeks() {
                        tikkunChatzotButton
                    }
                } header: {
                    VStack {
                        Text(getNightTitle(userChosenDate)).textCase(nil)
                    }
                }
                .textCase(nil)
            }
            
            Section {
                if showAllPrayers ? getSunsetBasedJewishCalendar(false).is3Weeks() : isPrayerCurrentlySaid(key: "תיקון חצות") {
                    tikkunChatzot3WeeksButton
                }
                birchatHamazonButton
                bmsButton
                if isNowNotAssurBemelacha() {
                    tefilatHaderechButton
                }
                siyumMasechetButton
                if !getSunsetBasedJewishCalendar().getBirchatLevanaStatus().isEmpty {
                    birchatHalevanaButton
                }
                if getSunsetBasedJewishCalendar().getYomTovIndex() == JewishCalendar.TU_BESHVAT {
                    prayerForEtrogButton
                }
                if getSunsetBasedJewishCalendar().getUpcomingParshah() == JewishCalendar.Parsha.BESHALACH &&
                    getSunsetBasedJewishCalendar().getDayOfWeek() == 3 {
                    parshatHamanButton
                }
            } header: {
                VStack {
                    Text("Misc.").textCase(nil)
                }
            }
            .textCase(nil)
            
            if !showAllPrayers {
                Section {
                    Button(action: {
                        showAllPrayers.toggle()
                    }) {
                        VStack(alignment: .leading) {
                            Text("See all prayers")
                        }
                    }
                } header: {
                    VStack {
                        Text("See more…").textCase(nil)
                    }
                }
            } else {
                Button(action: {
                    showAllPrayers.toggle()
                }) {
                    VStack(alignment: .leading) {
                        Text("See prayers currently applicable")
                    }
                }
            }
        }
    }

    var body: some View {
        alerts(view: mainList)
            .refreshable {
                userChosenDate = Date()
                syncCalendarDates()
            }
            .onAppear {
                adjustDateBasedOnSunset = true // reset previous setting
                if !Calendar.current.isDate(lastTimeUserWasInApp, inSameDayAs: Date()) && lastTimeUserWasInApp.timeIntervalSinceNow < 7200 {//2 hours
                    userChosenDate = Date()
                    GlobalStruct.userChosenDate = Date()
                    GlobalStruct.jewishCalendar.workingDate = GlobalStruct.userChosenDate
                }
                lastTimeUserWasInApp = Date()
                userChosenDate = GlobalStruct.userChosenDate
                syncCalendarDates()
                autoFillMasechta()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: JerDirectionView().applyToolbarHidden()) {
                        Image(systemName: "location.circle")
                    }
                }
            }
            .snackbar(isShowing: $showSelectSomethingSnackbar, title: "Please select at least one option".localized(), style: .error)
            .alert("When did you start your meal?", isPresented: $showBirchatHamazonAlert) {
                Button("Yes") {
                    if !showAllPrayers {
                        adjustDateBasedOnSunset = false
                    }
                    openSiddurView()
                }
                Button("No") {
                    adjustDateBasedOnSunset = true
                    siddurPrayer = "Birchat Hamazon+1"
                    openSiddurView()
                }
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text(getBeforeSunsetMessage())
            }.textCase(nil)
        
            .alert("When did you start your meal?", isPresented: $showMeEyinShaloshAlert) {
                Button("Yes") {
                    if !showAllPrayers {
                        adjustDateBasedOnSunset = false
                    }
                    openSiddurView()
                }
                Button("No") {
                    adjustDateBasedOnSunset = true
                    siddurPrayer = "Birchat MeEyin Shalosh+1"
                    openSiddurView()
                }
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text(getBeforeSunsetMessage())
            }.textCase(nil)
        
            .alert("Do you want to say Tikkun Chatzot for the day?", isPresented: $showTikkunChatzotDayOptionAlert) {
                Button("Yes") {
                    siddurPrayer = "Tikkun Chatzot (Day)"
                    openSiddurView()
                }
                Button("No") {
                    siddurPrayer = "Tikkun Chatzot+1"// this alert should only show if showAllPrayers is true, therefore, move it a day
                    openSiddurView()
                }
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text("During the three weeks, some say a shorter Tikkun Chatzot after mid-day. Are you looking to say this version of Tikkun Chatzot?")
            }.textCase(nil)
        
            .alert("Tikkun Chatzot is not said today or tonight", isPresented: $showTikkunChatzotNotSaidTodayOrTonightAlert) {
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text("Tikkun Chatzot is not said today or tonight. Possible reasons for why it is not said: It is Friday/Friday night, No Tachanun is said today, Erev Rosh Chodesh AV, Rosh Chodesh, Rosh Hashana, Yom Kippur, Succot/Shemini Atzeret, Pesach, or Shavuot.")
            }.textCase(nil)
        
            .alert("Tikkun Chatzot is not said tonight", isPresented: $showTikkunChatzotNotSaidTonightAlert) {
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text("Tikkun Chatzot is not said tonight. Possible reasons for why it is not said: It is Friday night, Rosh Hashana, Yom Kippur, Succot/Shemini Atzeret, Pesach, or Shavuot.")
            }.textCase(nil)
        
            .alert("Havdalah is only said on a flame tonight.", isPresented: $showHavdalaAlert) {
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text("Havdalah will be completed after the fast.".localized()
                    .appending("\n\n")
                    .appending("בָּרוּךְ אַתָּה יְהֹוָה, אֱלֹהֵֽינוּ מֶֽלֶךְ הָעוֹלָם, בּוֹרֵא מְאוֹרֵי הָאֵשׁ:"))
            }.textCase(nil)
        
            .alert("Are you in a walled (Mukaf Choma) city?", isPresented: $showMukafChomaAlert) {
                Button("Yes (Jerusalem)") {
                    GlobalStruct.jewishCalendar.setIsMukafChoma(isMukafChoma: true)
                    GlobalStruct.jewishCalendar.setIsSafekMukafChoma(isSafekMukafChoma: false)
                    showSiddur = true
                }
                Button("Doubt (Safek)") {
                    GlobalStruct.jewishCalendar.setIsMukafChoma(isMukafChoma: false)
                    GlobalStruct.jewishCalendar.setIsSafekMukafChoma(isSafekMukafChoma: true)
                    showSiddur = true
                }
                Button("No") {
                    // Undo any previous settings
                    GlobalStruct.jewishCalendar.setIsMukafChoma(isMukafChoma: false)
                    GlobalStruct.jewishCalendar.setIsSafekMukafChoma(isSafekMukafChoma: false)
                    showSiddur = true
                }
            } message: {
                Text("Are you located in a walled (Mukaf Choma) city from the time of Yehoshua Bin Nun?")
            }.textCase(nil)
        //NavigationLink("", isActive: $showSiddur) { SiddurView(prayer: siddurPrayer).applyToolbarHidden() }.hidden()// TODO fix
        NavigationLink("", isActive: $showSiddur) { UIKitSiddurControllerView()
                .navigationBarTitleDisplayMode(.inline)// fix for iOS 15/16
            .applyToolbarHidden() }.hidden()// Temp
        if showAllPrayers {
            HStack {
                Button {
                    userChosenDate = userChosenDate.advanced(by: -86400)
                    syncCalendarDates()
                } label: {
                    Image(systemName: "arrowtriangle.backward.fill").resizable().scaledToFit().frame(width: 18, height: 18)
                }
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
            }.padding(.init(top: 2, leading: 0, bottom: 8, trailing: 0))
        }
    }
    
    private func openSiddurView() {
        if (GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.PURIM || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM)
            && !siddurPrayer.contains("Birchat Halevana")
            && !siddurPrayer.contains("Tikkun Chatzot")
            && !siddurPrayer.contains("Kriat Shema SheAl Hamita")
            && !siddurPrayer.contains("Seder Siyum Masechet")
            && !siddurPrayer.contains("Tefilat HaDerech") {// if the prayer is dependant on isMukafChoma, we ask the user
            showMukafChomaAlert = true
        } else {
            if !showAllPrayers {
                GlobalStruct.jewishCalendar = getSunsetBasedJewishCalendar()
                let currentZmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
                currentZmanimCalendar.useElevation = GlobalStruct.useElevation
                let sunset = currentZmanimCalendar.getSunset()
                let tzeit = currentZmanimCalendar.getTzeitHacochavim(defaults: defaults)
                let plag = currentZmanimCalendar.getPlagHamincha()
                let isMinchaAfterSunsetBeforeTzeit = Date() > (sunset ?? Date()) && Date() < (tzeit ?? Date())
                let isArvitAfterPlagBeforeSunset = Date() > (plag ?? Date()) && Date() < (sunset ?? Date())
                if siddurPrayer == "Mincha" && isMinchaAfterSunsetBeforeTzeit {
                    GlobalStruct.jewishCalendar.back()
                }
                if siddurPrayer == "Arvit" && isArvitAfterPlagBeforeSunset {
                    GlobalStruct.jewishCalendar.forward()
                }
            }
            // I am only doing this because SwiftUI is designed poorly. If we do not wait to set the showSiddur boolean to true, SwiftUI will show the view too quickly and the String will be old. So we need to delay the initialization by putting it on a background thread... There is probably a better way to do this, but I did not see any better way with UIKit. TODO fix this later when the SwiftUI view is working
            DispatchQueue.main.async {
                showSiddur = true
            }
        }
    }
    
    private func autoFillMasechta() {
        selectedMasechtot.removeAll()
        let currentDaf = YomiCalculator.getDafYomiBavli(jewishCalendar: getSunsetBasedJewishCalendar());
        let nextDaf = YomiCalculator.getDafYomiBavli(jewishCalendar: getSunsetBasedJewishCalendar().tomorrow());

        if currentDaf?.getMasechta() != nextDaf?.getMasechta() {
            if currentDaf != nil {
                selectedMasechtot.append(currentDaf!.getMasechta())
            }
        }
    }
        
    private func getDayTitle(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        var weekday = dateFormatter.string(from: date)
        if Calendar.current.isDate(date, inSameDayAs: Date()) {
            weekday = weekday.appending(" (Today)".localized())
        }
        let hebrewDateFormatter = HebrewDateFormatter()
        hebrewDateFormatter.hebrewFormat = Locale.isHebrewLocale()

        var specialDayText = weekday
            .appending("\n")
            .appending(hebrewDateFormatter.format(jewishCalendar: getSunsetBasedJewishCalendar()))
        
        if !getSunsetBasedJewishCalendar().getSpecialDay(addOmer: false).isEmpty {
            specialDayText = specialDayText
                .appending("\n")
                .appending(getSunsetBasedJewishCalendar().getSpecialDay(addOmer: false))
        }
        if showAllPrayers {
            return specialDayText
        } else {
            let currentZmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
            currentZmanimCalendar.useElevation = GlobalStruct.useElevation
            return "Prayers able to be said now".localized()
                .appending("\n")
                .appending(getSunsetBasedJewishCalendar().currentToString(zmanimCalendar: currentZmanimCalendar))
        }
    }
    
    private func getNightTitle(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        var weekday = dateFormatter.string(from: date)
        if Calendar.current.isDate(date, inSameDayAs: Date()) {
            weekday = weekday.appending(" (Today)".localized())
        }
        let hebrewDateFormatter = HebrewDateFormatter()
        hebrewDateFormatter.hebrewFormat = Locale.isHebrewLocale()

        var tonightText = weekday
            .appending(" " + "(After Sunset)".localized())
            .appending("\n")
            .appending(hebrewDateFormatter.format(jewishCalendar: getSunsetBasedJewishCalendar(false).tomorrow()))
        if !getSunsetBasedJewishCalendar(false).tomorrow().getSpecialDay(addOmer: false).isEmpty {
            tonightText = tonightText
                .appending("\n")
                .appending(getSunsetBasedJewishCalendar(false).tomorrow().getSpecialDay(addOmer: false))
        }
        return tonightText
    }
    
    private func getBeforeSunsetMessage() -> String {
        let dateFormatterForZmanim = DateFormatter()
        dateFormatterForZmanim.dateFormat = Locale.isHebrewLocale() ? "H:mm" : "hh:mm a"
        let zmanimCalendar = ZmanimCalendar(location: GlobalStruct.geoLocation)
        zmanimCalendar.useElevation = GlobalStruct.useElevation
        zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate
        return "Did you start your meal before sunset?".localized()
            .appending(" ")
            .appending(dateFormatterForZmanim.string(from: zmanimCalendar.getElevationAdjustedSunset() ?? Date()))
    }

    /**
     Time bound method to check if it is currently NOT assur to do melacha.
     */
    private func isNowNotAssurBemelacha() -> Bool {
        let currentZmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
        currentZmanimCalendar.useElevation = GlobalStruct.useElevation
        let currentJewishCalendar = JewishCalendar(workingDate: Date(), timezone: .autoupdatingCurrent, inIsrael: GlobalStruct.jewishCalendar.inIsrael, useModernHolidays: true)
        // easier to check the case where it is Assur Bemelacha and NOT it
        return !(currentJewishCalendar.isAssurBemelacha() && Date() < (currentZmanimCalendar.getTzais13Point5MinutesZmanis() ?? Date())
        || (currentJewishCalendar.hasCandleLighting() && Date() > (currentZmanimCalendar.getSunset() ?? Date())))
    }
    
    private func handleBirchatHamazon() {
        let today = SiddurMaker(jewishCalendar: getSunsetBasedJewishCalendar(false)).getBirchatHamazonPrayers()
        let tomorrow = SiddurMaker(jewishCalendar: getSunsetBasedJewishCalendar(false).tomorrow()).getBirchatHamazonPrayers()

        if arePrayersEqual(today, tomorrow) {
            openSiddurView()
        } else {
            if showAllPrayers {
                showBirchatHamazonAlert = true
            } else {
                let currentZmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
                currentZmanimCalendar.useElevation = GlobalStruct.useElevation
                if Date() > currentZmanimCalendar.getElevationAdjustedSunset() ?? Date() {
                    showBirchatHamazonAlert = true
                } else {
                    openSiddurView()
                }
            }
        }
    }

    private func handleMeEyinShalosh() {
        let today = SiddurMaker(jewishCalendar: getSunsetBasedJewishCalendar(false)).getBirchatMeeyinShaloshPrayers(allItems: GlobalStruct.meEyinShaloshChoices)
        let tomorrow = SiddurMaker(jewishCalendar: getSunsetBasedJewishCalendar(false).tomorrow()).getBirchatMeeyinShaloshPrayers(allItems: GlobalStruct.meEyinShaloshChoices)
        
        if arePrayersEqual(today, tomorrow) {
            openSiddurView()
        } else {
            if showAllPrayers {
                showMeEyinShaloshAlert = true
            } else {
                let currentZmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
                currentZmanimCalendar.useElevation = GlobalStruct.useElevation
                if Date() > currentZmanimCalendar.getElevationAdjustedSunset() ?? Date() {
                    showMeEyinShaloshAlert = true
                } else {
                    openSiddurView()
                }
            }
        }
    }

    private func handleTikkunChatzot() {
        if showAllPrayers {
            if (getSunsetBasedJewishCalendar().is3Weeks()) {
                let isNightTikkunSaid = getSunsetBasedJewishCalendar().tomorrow().isNightTikkunChatzotSaid();
                let isDayTikkunSaid = getSunsetBasedJewishCalendar().isDayTikkunChatzotSaid();
                if (isNightTikkunSaid && isDayTikkunSaid) {// ask the user
                    showTikkunChatzotDayOptionAlert = true
                } else if (isDayTikkunSaid) {
                    siddurPrayer = "Tikkun Chatzot (Day)"
                    openSiddurView()
                } else if (isNightTikkunSaid) {
                    siddurPrayer = "Tikkun Chatzot+1"
                    openSiddurView()
                } else {
                    showTikkunChatzotNotSaidTodayOrTonightAlert = true
                }
            } else {// not the 3 weeks
                if (getSunsetBasedJewishCalendar().tomorrow().isNightTikkunChatzotSaid()) {
                    siddurPrayer = "Tikkun Chatzot+1"
                    openSiddurView()
                } else {
                    showTikkunChatzotNotSaidTonightAlert = true
                }
            }
        } else {
            if (getSunsetBasedJewishCalendar().is3Weeks()) {
                let currentZmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
                currentZmanimCalendar.useElevation = GlobalStruct.useElevation

                let isNightTikkunSaid = getSunsetBasedJewishCalendar().isNightTikkunChatzotSaid();
                let isDayTikkunSaid = getSunsetBasedJewishCalendar().isDayTikkunChatzotSaid();
                let isNowForDayTikkun = (Date() > currentZmanimCalendar.getChatzosIfHalfDayNil() ?? Date()) && (Date() < currentZmanimCalendar.getSunset() ?? Date());
                if (isNightTikkunSaid && isDayTikkunSaid) {// figure out which it is by the time
                    if isNowForDayTikkun {
                        siddurPrayer = "Tikkun Chatzot (Day)"
                    } else {
                        siddurPrayer = "Tikkun Chatzot"
                    }
                    openSiddurView()
                } else if (isDayTikkunSaid && isNowForDayTikkun) {
                    siddurPrayer = "Tikkun Chatzot (Day)"
                    openSiddurView()
                } else if (isNightTikkunSaid && !isNowForDayTikkun) {
                    siddurPrayer = "Tikkun Chatzot"
                    openSiddurView()
                } else {
                    showTikkunChatzotNotSaidTodayOrTonightAlert = true
                }
            } else {// not the 3 weeks
                if (getSunsetBasedJewishCalendar().isNightTikkunChatzotSaid()) {
                    siddurPrayer = "Tikkun Chatzot"
                    openSiddurView()
                } else {
                    showTikkunChatzotNotSaidTonightAlert = true
                }
            }
        }
    }

    private func arePrayersEqual(_ a: [HighlightString], _ b: [HighlightString]) -> Bool {
        guard a.count == b.count else { return false }
        return zip(a, b).allSatisfy { $0.string == $1.string }
    }
    
    func shouldBeDimmed(_ prayer: String) -> Bool {
        switch prayer {
        case "סליחות" :
            let currentZmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
            currentZmanimCalendar.useElevation = GlobalStruct.useElevation
            if Date() > currentZmanimCalendar.getTzeitHacochavim(defaults: defaults) ?? Date() && Date() < currentZmanimCalendar.getSolarMidnightIfSunTransitNil() ?? Date() {
                return true
            }
        case "תיקון חצות" :
            if (showAllPrayers) {
                if (getSunsetBasedJewishCalendar(false).is3Weeks()) {
                    return !getSunsetBasedJewishCalendar(false).isDayTikkunChatzotSaid() && !getSunsetBasedJewishCalendar(false).tomorrow().isNightTikkunChatzotSaid();// dim it if both the night and day are not said
                } else {// not the 3 weeks
                    return !getSunsetBasedJewishCalendar(false).tomorrow().isNightTikkunChatzotSaid();
                }
            } else {
                if (getSunsetBasedJewishCalendar().is3Weeks()) {
                    return !getSunsetBasedJewishCalendar().isDayTikkunChatzotSaid() && !getSunsetBasedJewishCalendar().isNightTikkunChatzotSaid();// dim it if both the night and day are not said
                } else {
                    return !getSunsetBasedJewishCalendar().isNightTikkunChatzotSaid();
                }
            }
        case "הבדלה" :
            if (showAllPrayers ?
                getSunsetBasedJewishCalendar().tomorrow().isTishaBav() && getSunsetBasedJewishCalendar().getDayOfWeek() == 7
                : getSunsetBasedJewishCalendar().isTishaBav() && getSunsetBasedJewishCalendar().getDayOfWeek() == 1 && isPrayerCurrentlySaid(key: "הבדלה")) {
                return true
            }
        default:
            return false
        }
        return false
    }
    
    private func isPrayerCurrentlySaid(key: String) -> Bool {
        let currentZmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
        currentZmanimCalendar.useElevation = GlobalStruct.useElevation
        if (currentZmanimCalendar.getSunset() == nil || currentZmanimCalendar.getSunrise() == nil) {
            return true;// show the prayer by default
        }
        var result = true
        switch (key) {
        case "סליחות":
            let isSelichotNotSaidNow = Date() > currentZmanimCalendar.getSunset()! && Date() < currentZmanimCalendar.getSecondAshmora()! || !currentZmanimCalendar.isNowAfterHalachicSolarMidnight()
            result = !isSelichotNotSaidNow
        case "שחרית":
            result = Date() > currentZmanimCalendar.getAlotHashachar(defaults: defaults)! && Date() < currentZmanimCalendar.getChatzosIfHalfDayNil()!
        case "מוסף":
            result = Date() > currentZmanimCalendar.getAlotHashachar(defaults: defaults)! && Date() < currentZmanimCalendar.getSunset()!
        case "מנחה":
            result = Date() > currentZmanimCalendar.getMinchaGedolaGreaterThan30()! && Date() < currentZmanimCalendar.getTzeitHacochavim(defaults: defaults)!
        case "ערבית":
            result = Date() > currentZmanimCalendar.getPlagHamincha()! || Date() < currentZmanimCalendar.getAlotHashachar(defaults: defaults)!
        case "ספירת העומר",
            "הדלקת נרות חנוכה",
            "הבדלה",
            "ק״ש שעל המיטה":
            result = Date() > currentZmanimCalendar.getSunset()! || Date() < currentZmanimCalendar.getAlotHashachar(defaults: defaults)!
        case "תיקון חצות (לילה)":
            result = !getSunsetBasedJewishCalendar().is3Weeks() && currentZmanimCalendar.isNowAfterHalachicSolarMidnight() && Date() < currentZmanimCalendar.getAlotHashachar(defaults: defaults)!
        case "תיקון חצות":
            result = getSunsetBasedJewishCalendar().is3Weeks() && ((currentZmanimCalendar.isNowAfterHalachicSolarMidnight() && Date() < currentZmanimCalendar.getAlotHashachar(defaults: defaults)!) || (Date() > currentZmanimCalendar.getChatzosIfHalfDayNil()! && Date() < currentZmanimCalendar.getSunset()! && getSunsetBasedJewishCalendar().getDayOfWeek() != 7))
        default:
            result = true
        }
        return result
    }
    
    func getSecondaryText(_ prayer: String) -> String? {
        var result: String? = nil
        let timeAdjustedJCal = getSunsetBasedJewishCalendar()
        let currentZmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
        currentZmanimCalendar.useElevation = GlobalStruct.useElevation
        let sunset = currentZmanimCalendar.getSunset()
        let tzeit = currentZmanimCalendar.getTzeitHacochavim(defaults: defaults)
        let plag = currentZmanimCalendar.getPlagHamincha()
        let isMinchaAfterSunsetBeforeTzeit = Date() > (sunset ?? Date()) && Date() < (tzeit ?? Date())
        let isArvitAfterPlagBeforeSunset = Date() > (plag ?? Date()) && Date() < (sunset ?? Date())

        switch prayer {
        case "סליחות":
            if timeAdjustedJCal.isAseresYemeiTeshuva() {
                result = "עשרת ימי תשובה"
            }
        case "שחרית":
            var entries:[String] = [
                timeAdjustedJCal.isRoshChodesh() || timeAdjustedJCal.isCholHamoed() ? "יעלה ויבוא" : "",
                timeAdjustedJCal.isPurim() || timeAdjustedJCal.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                timeAdjustedJCal.isChanukah() ? "על הניסים" : "",
                timeAdjustedJCal.getHallelOrChatziHallel() == "" ? timeAdjustedJCal.getTachanun()
                    .replacingOccurrences(of: "צדקתך", with: "")
                    .replacingOccurrences(of: "לא אומרים תחנון", with: "יהי שם")
                    .replacingOccurrences(of: "אומרים תחנון רק בבוקר", with: "תחנון")
                    .replacingOccurrences(of: "יש מדלגים תחנון במנחה", with: "תחנון")
                    .replacingOccurrences(of: "אומרים תחנון", with: "תחנון")

                    .replacingOccurrences(of: "No Tachanun today", with: "יהי שם")
                    .replacingOccurrences(of: "Tachanun only in the morning", with: "תחנון")
                    .replacingOccurrences(of: "Some say Tachanun today", with: "יש אומרים תחנון")
                    .replacingOccurrences(of: "Some skip Tachanun by mincha", with: "תחנון")
                    .replacingOccurrences(of: "There is Tachanun today", with: "תחנון")
                : timeAdjustedJCal.getHallelOrChatziHallel()
            ]
            entries = entries.filter { !$0.isEmpty }
            result = entries.joined(separator: ", ")
        case "מוסף":
            var entries:[String] = [
                timeAdjustedJCal.getIsUlChaparatPeshaSaid() == "אומרים וּלְכַפָּרַת פֶּשַׁע" || timeAdjustedJCal.getIsUlChaparatPeshaSaid() ==  "Say וּלְכַפָּרַת פֶּשַׁע" ?
                timeAdjustedJCal.getIsUlChaparatPeshaSaid()
                    .replacingOccurrences(of: "אומרים ", with: "")
                    .replacingOccurrences(of: "Say ", with: "") : "",
                timeAdjustedJCal.isPurim() || timeAdjustedJCal.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                timeAdjustedJCal.isChanukah() ? "על הניסים" : "",
            ]
            entries = entries.filter { !$0.isEmpty }
            result = entries.joined(separator: ", ")
        case "מנחה":
            if isMinchaAfterSunsetBeforeTzeit {
                timeAdjustedJCal.back()
            }
            var entries:[String] = [
                timeAdjustedJCal.isRoshChodesh() || timeAdjustedJCal.isCholHamoed() ? "יעלה ויבוא" : "",
                timeAdjustedJCal.isPurim() || timeAdjustedJCal.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                timeAdjustedJCal.isChanukah() ? "על הניסים" : "",
                timeAdjustedJCal.getTachanun()
                    .replacingOccurrences(of: "לא אומרים תחנון", with: "יהי שם")
                    .replacingOccurrences(of: "אומרים תחנון רק בבוקר", with: "יהי שם")
                    .replacingOccurrences(of: "יש מדלגים תחנון במנחה", with: "יש אומרים תחנון")
                    .replacingOccurrences(of: "אומרים תחנון", with: "תחנון")

                    .replacingOccurrences(of: "No Tachanun today", with: "יהי שם")
                    .replacingOccurrences(of: "Tachanun only in the morning", with: "יהי שם")
                    .replacingOccurrences(of: "Some say Tachanun today", with: "יש אומרים תחנון")
                    .replacingOccurrences(of: "Some skip Tachanun by mincha", with: "יש אומרים תחנון")
                    .replacingOccurrences(of: "There is Tachanun today", with: "תחנון")
            ]
            entries = entries.filter { !$0.isEmpty }
            result = entries.joined(separator: ", ")
            if isMinchaAfterSunsetBeforeTzeit {
                timeAdjustedJCal.forward()
            }
        case "ערבית":
            if showAllPrayers || isArvitAfterPlagBeforeSunset {
                timeAdjustedJCal.forward()
            }
            var entries:[String] = [
                timeAdjustedJCal.isRoshChodesh() ? "ברכי נפשי" : "",
                TefilaRules().isVeseinTalUmatarStartDate(jewishCalendar: timeAdjustedJCal) ? "ברך עלינו" : "",
                timeAdjustedJCal.isRoshChodesh() || timeAdjustedJCal.isCholHamoed() ? "יעלה ויבוא" : "",
                timeAdjustedJCal.isPurim() || timeAdjustedJCal.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                timeAdjustedJCal.isChanukah() ? "על הניסים" : ""
            ]
            entries = entries.filter { !$0.isEmpty }
            result = entries.joined(separator: ", ")
            if showAllPrayers || isArvitAfterPlagBeforeSunset {
                timeAdjustedJCal.back()
            }
        case "ספירת העומר":
            var omer = timeAdjustedJCal.getDayOfOmer();
            if (showAllPrayers) {
                omer = getSunsetBasedJewishCalendar(false).tomorrow().getDayOfOmer()
            }
            if (omer != -1) {
                return String(omer)
            }
        case "ברכת המזון":
            var entries:[String] = [
                timeAdjustedJCal.isPurim() || timeAdjustedJCal.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                timeAdjustedJCal.isChanukah() ? "על הניסים" : "",
                timeAdjustedJCal.getDayOfWeek() == 7 ? "[רצה]" : "",
                timeAdjustedJCal.isRoshChodesh() || timeAdjustedJCal.isCholHamoed() || timeAdjustedJCal.isYomTovAssurBemelacha() ? "יעלה ויבוא" : ""
            ]
            entries = entries.filter { !$0.isEmpty }
            result = entries.joined(separator: ", ")
        case "ק״ש שעל המיטה":
            return nil
        case "תיקון חצות (לילה)":
            if showAllPrayers {
                timeAdjustedJCal.forward()
            }
            if (timeAdjustedJCal.isNightTikkunChatzotSaid()) {
                if (timeAdjustedJCal.isTishaBav()) {
                    result = "תיקון רחל";
                } else {
                    result = timeAdjustedJCal.isOnlyTikkunLeiaSaid(forNightTikkun: true) ? "תיקון לאה" : "תיקון רחל ,תיקון לאה";
                }
            }
            if showAllPrayers {
                timeAdjustedJCal.back()
            }
        case "Prayer for Etrog".localized():
            return "It is good to say this prayer today.".localized()
        case "Parshat Haman".localized():
            return "It is good to say this prayer today.".localized()
        case "סדר סיום מסכת":
            let currentDaf = YomiCalculator.getDafYomiBavli(jewishCalendar: GlobalStruct.jewishCalendar);
            let nextDaf = YomiCalculator.getDafYomiBavli(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow());
            if currentDaf?.getMasechta() != nextDaf?.getMasechta() {
                if currentDaf != nil {
                    return currentDaf!.getMasechta()
                }
            }
            return nil
        default:
            return nil
        }
        
        if result?.count == 0 {
            result = nil
        }
        
        return result
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
}

// TEMP SOLUTION
struct UIKitSiddurControllerView : UIViewControllerRepresentable {
     func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
     func makeUIViewController(context: Context) -> some UIViewController {
         SiddurViewController.hideBackButton = true
         return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "Siddur")
     }
}

#Preview {
    SiddurChooserView()
}
