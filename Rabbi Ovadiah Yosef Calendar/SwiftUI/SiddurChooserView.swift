//
//  SiddurChooserView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 4/7/25.
//

import SwiftUI
import KosherSwift

@available(iOS 15.0, *)
struct SiddurChooserView: View {
    @State private var alertContent: AlertContent?
    @State private var alertType: AlertType?
    @State private var navigateToSiddur = false

    struct AlertContent: Identifiable {
        var id = UUID()
        var title: String
        var message: String
        var primaryAction: () -> Void
    }

    enum AlertType: Identifiable {
        case birchatHamazon
        case meEyinShalosh
        case tikkunChatzotDayOption
        case tikkunChatzotNotSaidToday

        var id: Int { hashValue }
    }

    var body: some View {
        List {
            NavigationLink("Shacharit", destination: SiddurView(prayer: "Shacharit").applyToolbarHidden())
            NavigationLink("Mincha", destination: SiddurView(prayer: "Mincha").applyToolbarHidden())
            NavigationLink("Arvit", destination: SiddurView(prayer: "Arvit").applyToolbarHidden())

//            Button(action: {
//                handleSelection(prayer: prayer.name)
//            }) {
//                VStack(alignment: .leading) {
//                    Text(prayer.name)
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(prayer.isDisabled ? .gray : .primary)
//                    if let secondary = prayer.secondary {
//                        Text(secondary)
//                            .font(.system(size: 16))
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
            
            // Optional: Include static buttons at the end
//            Section(header: Text("Other Prayers")) {
//                Button("Birchat Hamazon") { handleBirchatHamazon() }
//                Button("Birchat MeEyin Shalosh") { handleMeEyinShalosh() }
//                Button("Tikkun Chatzot") { handleTikkunChatzot() }
//            }
        }
        .onAppear {
            //self.sections = SiddurDataBuilder().buildSections()
        }
        .alert(item: $alertContent) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                primaryButton: .default(Text("OK"), action: alert.primaryAction),
                secondaryButton: .cancel()
            )
        }
        .alert(item: $alertType) { type in
            switch type {
            case .birchatHamazon:
                return createSunsetAlert(title: "Birchat Hamazon", yesPrayer: "", noPrayer: "")
            case .meEyinShalosh:
                return createSunsetAlert(title: "Birchat MeEyin Shalosh", yesPrayer: "", noPrayer: "")
            case .tikkunChatzotDayOption:
                return Alert(
                    title: Text("Say Tikkun Chatzot during the day?"),
                    message: Text("Some say it during the day during the 3 weeks."),
                    primaryButton: .default(Text("Yes")) {
                        //selectedPrayer = .tikkunChatzotDay
                        navigateToSiddur = true
                    },
                    secondaryButton: .default(Text("No")) {
                        //selectedPrayer = .tikkunChatzot
                        navigateToSiddur = true
                    }
                )
            case .tikkunChatzotNotSaidToday:
                return Alert(title: Text("Tikkun Chatzot is not said tonight."))
            }
        }
//        .background(
//            NavigationLink(
//                destination: SiddurView(prayer: ""), // customize SiddurView with selectedPrayer if needed
//                isActive: $navigateToSiddur
//            ) { EmptyView() }
//        )
    }

    // MARK: - Prayer Selection
    private func handleSelection(prayer: String) {
        switch prayer {
        case "סליחות": GlobalStruct.chosenPrayer = "Selichot"
        case "שחרית": GlobalStruct.chosenPrayer = "Shacharit"
        case "מוסף": GlobalStruct.chosenPrayer = "Mussaf"
        case "מנחה": GlobalStruct.chosenPrayer = "Mincha"
        case "ערבית": GlobalStruct.chosenPrayer = "Arvit"
        case "ק״ש שעל המיטה": GlobalStruct.chosenPrayer = "Kriat Shema SheAl Hamita"
        case "הדלקת נרות חנוכה": GlobalStruct.chosenPrayer = "Hadlakat Neirot Chanuka"
        case "ברכת הלבנה": GlobalStruct.chosenPrayer = "Birchat Halevana"
        case "הבדלה":
            if GlobalStruct.jewishCalendar.tomorrow().isTishaBav() &&
                GlobalStruct.jewishCalendar.getDayOfWeek() == 7 {
                alertContent = AlertContent(
                    title: "Havdalah is only said on a flame tonight.".localized(),
                    message: "Havdalah will be completed after the fast.".localized().appending("\n\n").appending("בָּרוּךְ אַתָּה יְהֹוָה, אֱלֹהֵֽינוּ מֶֽלֶךְ הָעוֹלָם, בּוֹרֵא מְאוֹרֵי הָאֵשׁ:"),
                    primaryAction: {
                        GlobalStruct.jewishCalendar.setIsMukafChoma(isMukafChoma: true)
                        GlobalStruct.jewishCalendar.setIsSafekMukafChoma(isSafekMukafChoma: false)
                        showFullScreenSiddur()
                    }
                )
                return
            }
            GlobalStruct.chosenPrayer = "Havdala"
        case "ברכת המזון": handleBirchatHamazon(); return
        case "ברכת מעין שלוש": handleMeEyinShalosh(); return
        case "תיקון חצות": handleTikkunChatzot(); return
        default:
            if GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.TU_BESHVAT {
                //openEtrogPrayerLink()
            } else {
                //openParshatHamanPrayerLink()
            }
            return
        }

        showFullScreenSiddur()
    }

    // MARK: - Special Cases
    private func handleBirchatHamazon() {
        let today = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHamazonPrayers()
        GlobalStruct.jewishCalendar.forward()
        let tomorrow = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHamazonPrayers()
        GlobalStruct.jewishCalendar.back()

        if !arePrayersEqual(today, tomorrow) {
            alertType = .birchatHamazon
        } else {
            //selectedPrayer = .birchatHamazon
            navigateToSiddur = true
        }
    }

    private func handleMeEyinShalosh() {
        let today = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatMeeyinShaloshPrayers()
        GlobalStruct.jewishCalendar.forward()
        let tomorrow = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatMeeyinShaloshPrayers()
        GlobalStruct.jewishCalendar.back()

        if !arePrayersEqual(today, tomorrow) {
            alertType = .meEyinShalosh
        } else {
            //selectedPrayer = .meEyinShalosh
            navigateToSiddur = true
        }
    }

    private func handleTikkunChatzot() {
        if GlobalStruct.jewishCalendar.is3Weeks() {
            let tachanun = GlobalStruct.jewishCalendar.getTachanun()
            let isTachanunSaid = ["Tachanun only in the morning", "There is Tachanun today", "אומרים תחנון רק בבוקר", "אומרים תחנון"].contains(tachanun)

            if GlobalStruct.jewishCalendar.isDayTikkunChatzotSaid(), isTachanunSaid {
                alertType = .tikkunChatzotDayOption
                return
            }
        }

        GlobalStruct.jewishCalendar.forward()
        let isSaid = GlobalStruct.jewishCalendar.isNightTikkunChatzotSaid()
        GlobalStruct.jewishCalendar.back()

        if isSaid {
            //selectedPrayer = .tikkunChatzot
            navigateToSiddur = true
        } else {
            alertType = .tikkunChatzotNotSaidToday
        }
    }

    // MARK: - Helpers
    private func arePrayersEqual(_ a: [HighlightString], _ b: [HighlightString]) -> Bool {
        guard a.count == b.count else { return false }
        return zip(a, b).allSatisfy { $0.string == $1.string }
    }

    private func createSunsetAlert(title: String, yesPrayer: String, noPrayer: String) -> Alert {
        let zmanimCalendar = ZmanimCalendar(location: GlobalStruct.geoLocation)
        zmanimCalendar.useElevation = GlobalStruct.useElevation
        zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate

        let sunset = zmanimCalendar.getElevationAdjustedSunset() ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = Locale.isHebrewLocale() ? "H:mm" : "h:mm a"

        return Alert(
            title: Text(title),
            message: Text("Did you start your meal before sunset? \(formatter.string(from: sunset))"),
            primaryButton: .default(Text("Yes")) {
                //selectedPrayer = yesPrayer
                navigateToSiddur = true
            },
            secondaryButton: .default(Text("No")) {
                //selectedPrayer = noPrayer
                navigateToSiddur = true
            }
        )
    }

    private func showFullScreenSiddur() {
        navigateToSiddur = true
    }
}


#Preview {
    if #available(iOS 15.0, *) {
        SiddurChooserView()
    } else {
        // Fallback on earlier versions
    }
}
