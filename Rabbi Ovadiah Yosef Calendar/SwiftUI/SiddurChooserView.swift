//
//  SiddurChooserView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 4/7/25.
//

import SwiftUI
import KosherSwift
import SwiftUISnackbar

@available(iOS 15.0, *)
struct SiddurChooserView: View {
    @State private var siddurPrayer = "" {
        didSet {
            GlobalStruct.chosenPrayer = siddurPrayer
        }
    }
    @State private var showSiddur = false

    @State var userChosenDate: Date = GlobalStruct.userChosenDate
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

    func syncCalendarDates() {//with userChosenDate
        GlobalStruct.jewishCalendar.workingDate = userChosenDate
        GlobalStruct.userChosenDate = userChosenDate
    }

    var body: some View {
        alerts(view:
                List {
            Section {
                if GlobalStruct.jewishCalendar.isSelichotSaid() {
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
                if GlobalStruct.jewishCalendar.isRoshChodesh() || GlobalStruct.jewishCalendar.isCholHamoed() {
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
            } header: {
                VStack {
                    Text(getDayTitle(userChosenDate)).textCase(nil)
                }
            }.textCase(nil)
            Section {
                Button(action: {
                    siddurPrayer = "Arvit"
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
                if !(GlobalStruct.jewishCalendar.tomorrow().getDayOfOmer() == -1 || GlobalStruct.jewishCalendar.getDayOfOmer() >= 49) {
                    Button(action: {
                        siddurPrayer = "Sefirat HaOmer+1"
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
                if (GlobalStruct.jewishCalendar.tomorrow().isChanukah() || GlobalStruct.jewishCalendar.isChanukah() && GlobalStruct.jewishCalendar.getDayOfChanukah() != 8) {
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
                if !GlobalStruct.jewishCalendar.hasCandleLighting() && GlobalStruct.jewishCalendar.isAssurBemelacha() || (GlobalStruct.jewishCalendar.isTishaBav() && (GlobalStruct.jewishCalendar.getDayOfWeek() == 7 || GlobalStruct.jewishCalendar.getDayOfWeek() == 1)) {
                    Button(action: {
                        if (GlobalStruct.jewishCalendar.tomorrow().isTishaBav() && GlobalStruct.jewishCalendar.getDayOfWeek() == 7) {
                            showHavdalaAlert = true
                        } else {
                            siddurPrayer = "Havdala"
                            openSiddurView()
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
                Button(action: {
                    siddurPrayer = "Kriat Shema SheAl Hamita"
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
                if !GlobalStruct.jewishCalendar.is3Weeks() {
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
            } header: {
                VStack {
                    Text(getNightTitle(userChosenDate)).textCase(nil)
                }
            }.textCase(nil)
            Section {
                if GlobalStruct.jewishCalendar.is3Weeks() {
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
                if isNotAssurBemelacha() {
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
                if !GlobalStruct.jewishCalendar.getBirchatLevanaStatus().isEmpty {
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
                if GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.TU_BESHVAT {
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
                if GlobalStruct.jewishCalendar.getUpcomingParshah() == JewishCalendar.Parsha.BESHALACH &&
                    GlobalStruct.jewishCalendar.getDayOfWeek() == 3 {
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
            } header: {
                VStack {
                    Text("Misc.").textCase(nil)
                }
            }.textCase(nil)
        }
            .refreshable {
                userChosenDate = Date()
                syncCalendarDates()
            }
            .onAppear {
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
                    openSiddurView()
                }
                Button("No") {
                    siddurPrayer = "Birchat Hamazon+1"
                    openSiddurView()
                }
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text(getBeforeSunsetMessage())
            }.textCase(nil)

            .alert("When did you start your meal?", isPresented: $showMeEyinShaloshAlert) {
                Button("Yes") {
                    openSiddurView()
                }
                Button("No") {
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
                    siddurPrayer = "Tikkun Chatzot"
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
        )
        //NavigationLink("", isActive: $showSiddur) { SiddurView(prayer: siddurPrayer).applyToolbarHidden() }.hidden()// TODO fix
        NavigationLink("", isActive: $showSiddur) { UIKitSiddurControllerView().applyToolbarHidden() }.hidden()// Temp
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

    private func openSiddurView() {
        if (GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.PURIM || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM) && siddurPrayer != "Birchat Halevana" && !siddurPrayer.contains("Tikkun Chatzot") && siddurPrayer != "Kriat Shema SheAl Hamita" && siddurPrayer != "Seder Siyum Masechet" && siddurPrayer != "Tefilat HaDerech" {// if the prayer is dependant on isMukafChoma, we ask the user
            showMukafChomaAlert = true
        } else {
            // I am only doing this because SwiftUI is designed poorly. If we do not wait to set the showSiddur boolean to true, SwiftUI will show the view too quickly and the String will be old. So we need to delay the initialization by putting it on a background thread... There is probably a better way to do this, but I did not see any better way. TODO fix this later
            DispatchQueue.main.async {
                showSiddur = true
            }
        }
    }

    private func autoFillMasechta() {
        selectedMasechtot.removeAll()
        let currentDaf = YomiCalculator.getDafYomiBavli(jewishCalendar: GlobalStruct.jewishCalendar);
        let nextDaf = YomiCalculator.getDafYomiBavli(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow());

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
            .appending(hebrewDateFormatter.format(jewishCalendar: GlobalStruct.jewishCalendar))

        if !GlobalStruct.jewishCalendar.getSpecialDay(addOmer: false).isEmpty {
            specialDayText = specialDayText
                .appending("\n")
                .appending(GlobalStruct.jewishCalendar.getSpecialDay(addOmer: false))
        }
        return specialDayText
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
            .appending(hebrewDateFormatter.format(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()))
        if !GlobalStruct.jewishCalendar.tomorrow().getSpecialDay(addOmer: false).isEmpty {
            tonightText = tonightText
                .appending("\n")
                .appending(GlobalStruct.jewishCalendar.tomorrow().getSpecialDay(addOmer: false))
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

    private func isNotAssurBemelacha() -> Bool {
        let zmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
        zmanimCalendar.useElevation = GlobalStruct.useElevation
        zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate
        return !(GlobalStruct.jewishCalendar.isAssurBemelacha() && Date().timeIntervalSince1970 < zmanimCalendar.getTzais13Point5MinutesZmanis()?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        || (GlobalStruct.jewishCalendar.hasCandleLighting() && Date().timeIntervalSince1970 > zmanimCalendar.getSunset()?.timeIntervalSince1970 ?? 0))
    }

    private func handleBirchatHamazon() {
        let today = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHamazonPrayers()
        let tomorrow = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getBirchatHamazonPrayers()

        if !arePrayersEqual(today, tomorrow) {
            showBirchatHamazonAlert = true
        } else {
            openSiddurView()
        }
    }

    private func handleMeEyinShalosh() {
        let today = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatMeeyinShaloshPrayers(allItems: GlobalStruct.meEyinShaloshChoices)
        let tomorrow = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getBirchatMeeyinShaloshPrayers(allItems: GlobalStruct.meEyinShaloshChoices)

        if !arePrayersEqual(today, tomorrow) {
            showMeEyinShaloshAlert = true
        } else {
            openSiddurView()
        }
    }

    private func handleTikkunChatzot() {
        if (GlobalStruct.jewishCalendar.is3Weeks()) {
            let isTachanunSaid = GlobalStruct.jewishCalendar.getTachanun() == "Tachanun only in the morning"
            || GlobalStruct.jewishCalendar.getTachanun() == "אומרים תחנון רק בבוקר"
            || GlobalStruct.jewishCalendar.getTachanun() == "אומרים תחנון"
            || GlobalStruct.jewishCalendar.getTachanun() == "There is Tachanun today"
            if (GlobalStruct.jewishCalendar.isDayTikkunChatzotSaid() && isTachanunSaid) {
                showTikkunChatzotDayOptionAlert = true
            } else {
                if (GlobalStruct.jewishCalendar.tomorrow().isNightTikkunChatzotSaid()) {
                    siddurPrayer = "Tikkun Chatzot"
                    GlobalStruct.chosenPrayer = siddurPrayer
                    openSiddurView()
                } else {
                    showTikkunChatzotNotSaidTodayOrTonightAlert = true
                }
            }
        } else {// Not three weeks
            if (GlobalStruct.jewishCalendar.tomorrow().isNightTikkunChatzotSaid()) {
                siddurPrayer = "Tikkun Chatzot"
                GlobalStruct.chosenPrayer = siddurPrayer
                openSiddurView()
            } else {
                showTikkunChatzotNotSaidTonightAlert = true
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
            let zmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
            zmanimCalendar.useElevation = GlobalStruct.useElevation
            zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate
            var tzeit = Date()
            if defaults.bool(forKey: "LuachAmudeiHoraah") {
                tzeit = zmanimCalendar.getTzaisAmudeiHoraah() ?? Date()
            } else {
                tzeit = zmanimCalendar.getTzais13Point5MinutesZmanis() ?? Date();
            }
            if Date().compare(tzeit) == .orderedDescending && Date().compare(zmanimCalendar.getSolarMidnightIfSunTransitNil() ?? Date()) == .orderedAscending {
                return true
            }
        case "תיקון חצות" :
            if (GlobalStruct.jewishCalendar.is3Weeks()) {
                let isTachanunSaid = GlobalStruct.jewishCalendar.getTachanun() == "Tachanun only in the morning"
                          || GlobalStruct.jewishCalendar.getTachanun() == "אומרים תחנון רק בבוקר"
                          || GlobalStruct.jewishCalendar.getTachanun() == "אומרים תחנון"
                          || GlobalStruct.jewishCalendar.getTachanun() == "There is Tachanun today"
                  if (!GlobalStruct.jewishCalendar.isDayTikkunChatzotSaid() || !isTachanunSaid) {
                      if (!GlobalStruct.jewishCalendar.tomorrow().isNightTikkunChatzotSaid()) {// i.e. both are not said
                          return true
                      }
                  }
              } else {// not three weeks
                  if (!GlobalStruct.jewishCalendar.tomorrow().isNightTikkunChatzotSaid()) {
                      return true
                  }
              }
        case "הבדלה" :
            if (GlobalStruct.jewishCalendar.tomorrow().isTishaBav() && GlobalStruct.jewishCalendar.getDayOfWeek() == 7) {
                return true
            }
        default:
            return false
        }
        return false
    }

    func getSecondaryText(_ prayer: String) -> String? {
        var result: String? = nil
        switch prayer {
        case "סליחות":
            if GlobalStruct.jewishCalendar.isAseresYemeiTeshuva() {
                result = "עשרת ימי תשובה"
            }
        case "שחרית":
            var entries:[String] = [
                GlobalStruct.jewishCalendar.isRoshChodesh() || GlobalStruct.jewishCalendar.isCholHamoed() ? "יעלה ויבוא" : "",
                GlobalStruct.jewishCalendar.isPurim() || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                GlobalStruct.jewishCalendar.isChanukah() ? "על הניסים" : "",
                GlobalStruct.jewishCalendar.getHallelOrChatziHallel() == "" ? GlobalStruct.jewishCalendar.getTachanun()
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
                : GlobalStruct.jewishCalendar.getHallelOrChatziHallel()
            ]
            entries = entries.filter { !$0.isEmpty }
            result = entries.joined(separator: ", ")
        case "מוסף":
            var entries:[String] = [
                GlobalStruct.jewishCalendar.getIsUlChaparatPeshaSaid() == "אומרים וּלְכַפָּרַת פֶּשַׁע" || GlobalStruct.jewishCalendar.getIsUlChaparatPeshaSaid() ==  "Say וּלְכַפָּרַת פֶּשַׁע" ?
                GlobalStruct.jewishCalendar.getIsUlChaparatPeshaSaid()
                    .replacingOccurrences(of: "אומרים ", with: "")
                    .replacingOccurrences(of: "Say ", with: "") : "",
                GlobalStruct.jewishCalendar.isPurim() || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                GlobalStruct.jewishCalendar.isChanukah() ? "על הניסים" : "",
            ]
            entries = entries.filter { !$0.isEmpty }
            result = entries.joined(separator: ", ")
        case "מנחה":
            var entries:[String] = [
                GlobalStruct.jewishCalendar.isRoshChodesh() || GlobalStruct.jewishCalendar.isCholHamoed() ? "יעלה ויבוא" : "",
                GlobalStruct.jewishCalendar.isPurim() || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                GlobalStruct.jewishCalendar.isChanukah() ? "על הניסים" : "",
                GlobalStruct.jewishCalendar.getTachanun()
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
        case "ערבית":
            GlobalStruct.jewishCalendar.forward()
            var entries:[String] = [
                GlobalStruct.jewishCalendar.isRoshChodesh() ? "ברכי נפשי" : "",
                TefilaRules().isVeseinTalUmatarStartDate(jewishCalendar: GlobalStruct.jewishCalendar) ? "ברך עלינו" : "",
                GlobalStruct.jewishCalendar.isRoshChodesh() || GlobalStruct.jewishCalendar.isCholHamoed() ? "יעלה ויבוא" : "",
                GlobalStruct.jewishCalendar.isPurim() || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                GlobalStruct.jewishCalendar.isChanukah() ? "על הניסים" : ""
            ]
            GlobalStruct.jewishCalendar.back()
            entries = entries.filter { !$0.isEmpty }
            result = entries.joined(separator: ", ")
        case "ברכת המזון":
            var entries:[String] = [
                GlobalStruct.jewishCalendar.isPurim() || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                GlobalStruct.jewishCalendar.isChanukah() ? "על הניסים" : "",
                GlobalStruct.jewishCalendar.getDayOfWeek() == 7 ? "[רצה]" : "",
                GlobalStruct.jewishCalendar.isRoshChodesh() || GlobalStruct.jewishCalendar.isCholHamoed() || GlobalStruct.jewishCalendar.isYomTovAssurBemelacha() ? "יעלה ויבוא" : ""
            ]
            entries = entries.filter { !$0.isEmpty }
            result = entries.joined(separator: ", ")
        case "ק״ש שעל המיטה":
            return nil
        case "Prayer for Etrog".localized():
            return "It is good to say this prayer today.".localized()
        case "Parshat Haman".localized():
            return "It is good to say this prayer today.".localized()
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
    if #available(iOS 15.0, *) {
        SiddurChooserView()
    } else {
        // Fallback on earlier versions
    }
}
