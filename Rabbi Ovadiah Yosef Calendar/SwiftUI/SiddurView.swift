//
//  SiddurView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 4/7/25.
//

import SwiftUI
import KosherSwift
import FrameUp

@available(iOS 15.0, *)
struct SiddurView: View {

    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var categoriesFound = false
    var fontName = "Guttman Keren"
    @State var prayer: String
    @State var listOfTexts: [HighlightString]
    @State var dropDownTitle: String
    @State var textSize: Float = 16.0
    @State var isJustified = false
    @State var goToMussaf = false
    @StateObject private var compassVM = CompassViewModel()

    init(prayer: String) {
        let zmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
        zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate
        fontName = defaults.string(forKey: "fontName") ?? "Guttman Keren"
        self.prayer = prayer
        switch prayer {
        case "Selichot":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getSelichotPrayers(isAfterChatzot: Date().timeIntervalSince1970 > zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0
            && Date().timeIntervalSince1970 < (zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0) + 7200)
            self.dropDownTitle = "סליחות"
        case "Shacharit":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getShacharitPrayers()
            self.dropDownTitle = "שחרית"
        case "Mussaf":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getMusafPrayers()
            self.dropDownTitle = "מוסף"
        case "Mincha":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getMinchaPrayers()
            self.dropDownTitle = "מנחה"
        case "Arvit":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getArvitPrayers()
            self.dropDownTitle = "ערבית"
        case "Sefirat HaOmer":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getSefiratHaOmer()
            dropDownTitle = "ספירת העומר"
        case "Birchat Hamazon":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHamazonPrayers()
            self.dropDownTitle = "ברכת המזון"
        case "Birchat Hamazon+1":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getBirchatHamazonPrayers()
            self.dropDownTitle = "ברכת המזון"
        case "Tefilat HaDerech":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getTefilatHaderechPrayer()
            self.dropDownTitle = "תפלת הדרך"
        case "Birchat Halevana":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHalevanaPrayers()
            self.dropDownTitle = "ברכת הלבנה"
        case "Seder Siyum Masechet":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getSiyumMasechetPrayer(masechtas: GlobalStruct.siyumChoices)
            dropDownTitle = "סדר סיום מסכת"
        case "Tikkun Chatzot (Day)":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getTikkunChatzotPrayers(isForNight: false)
            self.dropDownTitle = "תיקון חצות"
        case "Tikkun Chatzot":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getTikkunChatzotPrayers(isForNight: true)
            self.dropDownTitle = "תיקון חצות"
        case "Kriat Shema SheAl Hamita":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getKriatShemaShealHamitaPrayers(isBeforeChatzot: Date().timeIntervalSince1970 < zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0)
            self.dropDownTitle = "ק״ש שעל המיטה"
        case "Birchat MeEyin Shalosh":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatMeeyinShaloshPrayers(allItems: GlobalStruct.meEyinShaloshChoices)
            self.dropDownTitle = "ברכת מעין שלוש"
        case "Birchat MeEyin Shalosh+1":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getBirchatMeeyinShaloshPrayers(allItems: GlobalStruct.meEyinShaloshChoices)
            self.dropDownTitle = "ברכת מעין שלוש"
        case "Hadlakat Neirot Chanuka":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getHadlakatNeirotChanukaPrayers()
            self.dropDownTitle = "הדלקת נרות חנוכה"
        case "Havdala":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getHavdalahPrayers()
            self.dropDownTitle = "הבדלה"
        default:
            self.listOfTexts = []
            self.dropDownTitle = ""
        }
        for text in listOfTexts {
            if text.isCategory {
                categoriesFound = true
                continue
            }
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(listOfTexts) { text in
                        if text.string == "(Use this compass to help you find which direction South is in. Do not hold your phone straight up or place it on a table, hold it normally.) " +
                            "עזר לך למצוא את הכיוון הדרומי באמצעות המצפן הזה. אל תחזיק את הטלפון שלך בצורה ישרה למעלה או תנה אותו על שולחן, תחזיק אותו בצורה רגילה.:" {
                            Image("compass")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 200, height: 200)
                                 .rotationEffect(.degrees(compassVM.heading))
                                 .animation(.easeInOut, value: compassVM.heading)
                        } else if text.string == "Mussaf is said here, press here to go to Mussaf" || text.string == "מוסף אומרים כאן, לחץ כאן כדי להמשיך למוסף" {
                            Button(text.string) {
                                goToMussaf = true
                            }
                            .foregroundStyle(text.shouldBeHighlighted ? Color.black : Color.primary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding()
                            .background(text.shouldBeHighlighted ? Color.init("SiddurHighlightBackgroundColor") : Color.clear)
                            .multilineTextAlignment(.trailing)
                            NavigationLink("", isActive: $goToMussaf) { SiddurView(prayer: "Mussaf").applyToolbarHidden() }.hidden()
                        } else if text.string == "Open Sefaria Siddur/פתח את סידור ספריה" {
                            Button(text.string) {
                                if let url = URL(string: "https://www.sefaria.org/Siddur_Edot_HaMizrach") {
                                        UIApplication.shared.open(url)
                                }
                            }
                            .foregroundStyle(text.shouldBeHighlighted ? Color.black : Color.primary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding()
                            .background(text.shouldBeHighlighted ? Color.init("SiddurHighlightBackgroundColor") : Color.clear)
                            .multilineTextAlignment(.trailing)
                        } else if text.isCategory {
                            JustifiedText(text.string, font: UIFont.init(name: "Guttman Mantova", size: CGFloat(textSize + 8))!, isJustified: isJustified)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom)
                                .id(text)
                        } else if text.string == "[break here]" {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.secondary)
                        } else {
                            JustifiedText(text.string, font: UIFont.init(name: fontName, size: CGFloat(textSize)) ?? UIFont.systemFont(ofSize: CGFloat(textSize)), isJustified: isJustified)
                                .foregroundStyle(text.shouldBeHighlighted ? Color.black : Color.primary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding()
                                .background(text.shouldBeHighlighted ? Color.init("SiddurHighlightBackgroundColor") : Color.clear)
                                .multilineTextAlignment(.trailing)
                            // TODO there is an issue with text justification being backwards and slow even in a lazyvstack
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Menu {
                        ForEach(listOfTexts, id: \.self) { text in
                            if text.isCategory {
                                Button(action: {
                                    proxy.scrollTo(text, anchor: .top)
                                }) {
                                    Text(text.string)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrowtriangle.down.circle.fill")
                            Text(dropDownTitle)
                        }
                    }
                    .disabled(!categoriesFound)
                }
            }
        }
        HStack {
            Slider(value: $textSize, in: 10...50)
                .onChange(of: textSize) { newValue in
                    defaults.set(newValue, forKey: "textSize")
                }
            Button(action: {
                isJustified.toggle()
                defaults.set(isJustified, forKey: "JustifyText")
            }) {
                if isJustified {
                    Image(systemName: "text.alignright")
                } else {
                    Image(systemName: "text.justify")
                }
            }
            .padding()
        }
        .onAppear {
            if defaults.float(forKey: "textSize") == 0.0 {
                textSize = 16
                defaults.set(16, forKey: "textSize")
            }
            textSize = defaults.float(forKey: "textSize")
            isJustified = defaults.bool(forKey: "JustifyText")
        }
    }
}

import CoreLocation
import Combine

class CompassViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var heading: Double = 0.0

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        // Start location services to get the true heading.
        locationManager.distanceFilter = 1000
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()

        // Start heading updating.
        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }

        let headingDegrees = (newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading)
        DispatchQueue.main.async {
            self.heading = -headingDegrees  // Negative to rotate correctly like a real compass
        }
    }
}

#Preview {
    if #available(iOS 15.0, *) {
        SiddurView(prayer: "Arvit")
    } else {
        // Fallback on earlier versions
    }
}
