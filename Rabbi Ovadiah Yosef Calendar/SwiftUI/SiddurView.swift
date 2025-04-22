//
//  SiddurView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 4/7/25.
//

import SwiftUI
import KosherSwift

@available(iOS 15.0, *)
struct SiddurView: View {
    
    @State var prayer: String
    @State var listOfTexts: [HighlightString]
    @State var dropDownTitle: String
    @State var textSize: CGFloat = 16
    
    init(prayer: String) {
        let zmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
        zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate
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
        case "Birchat Hamazon":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHamazonPrayers()
            self.dropDownTitle = "ברכת המזון"
        case "Birchat Hamazon+1":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getBirchatHamazonPrayers()
            self.dropDownTitle = "ברכת המזון"
        case "Birchat Halevana":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHalevanaPrayers()
            self.dropDownTitle = "ברכת הלבנה"
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
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatMeeyinShaloshPrayers()
            self.dropDownTitle = "ברכת מעין שלוש"
        case "Birchat MeEyin Shalosh+1":
            self.listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getBirchatMeeyinShaloshPrayers()
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
        listOfTexts = appendUnicodeForDuplicates(in: listOfTexts)// to fix the issue of going to the same place for different categories with the same name
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(listOfTexts) { text in
                    if text.isCategory {
                        Text(text.string)
                            .font(Font.custom("MANTB 2", size: textSize))
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text(text.string)
                            .font(Font.custom("Guttman Keren", size: textSize))
                            .foregroundStyle(text.shouldBeHighlighted ? Color.yellow : Color.primary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }.padding()
        }
        Slider(value: $textSize, in: 10...30)
    }
    
    func appendUnicodeForDuplicates(in array: Array<HighlightString>) -> Array<HighlightString> {
        var counts = [String: Int]()  // Dictionary to track occurrences
        var result = Array<HighlightString>()
        
        for str in array {
            if !str.isCategory {
                result.append(str)
                continue
            }
            if let count = counts[str.string] {
                counts[str.string] = count + 1  // Increment occurrence count
                let modifiedString = str.string + String(repeating: "\u{200E}", count: count)  // Append an invisible char for each occurrence
                result.append(HighlightString(modifiedString, shouldBeHighlighted: str.shouldBeHighlighted, isCategory: str.isCategory))
            } else {
                counts[str.string] = 1  // First occurrence
                result.append(str)
            }
        }
        
        return result
    }
}

#Preview {
    if #available(iOS 15.0, *) {
        SiddurView(prayer: "Shacharit")
    } else {
        // Fallback on earlier versions
    }
}
