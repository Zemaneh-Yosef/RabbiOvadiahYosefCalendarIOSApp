//
//  SiddurChooserViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by User on 9/27/23.
//

import UIKit
import KosherSwift

class SiddurChooserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var zmanimCalendar = ComplexZmanimCalendar()
    var lastTimeUserWasInApp: Date = Date()
    let dateFormatterForZmanim = DateFormatter()
    var specialDayText = ""
    var tonightText = ""
    var choices: [String: [String]] = [
        "morning": [],
        "night": [],
        "misc": []
    ]

    @IBOutlet weak var tableview: UITableView!
    @IBAction func nextDay(_ sender: UIButton) {
        GlobalStruct.userChosenDate = GlobalStruct.userChosenDate.advanced(by: 86400)
        GlobalStruct.jewishCalendar.workingDate = GlobalStruct.userChosenDate
        loadView()
        viewDidLoad()
    }
    @IBAction func calendarButton(_ sender: UIButton) {
        showDatePicker()
    }
    @IBAction func prevDay(_ sender: UIButton) {
        GlobalStruct.userChosenDate = GlobalStruct.userChosenDate.advanced(by: -86400)
        GlobalStruct.jewishCalendar.workingDate = GlobalStruct.userChosenDate
        loadView()
        viewDidLoad()
    }
    @IBOutlet weak var viewContainingToolbar: UIView!
    @IBAction func jerDirection(_ sender: UIButton) {
        showFullScreenView("jerDirection")
    }

    func birchatHamazon() {
        GlobalStruct.chosenPrayer = "Birchat Hamazon"
        let today = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHamazonPrayers()
        GlobalStruct.jewishCalendar.forward()
        let tomorrow = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHamazonPrayers()
        GlobalStruct.jewishCalendar.back()//reset
        
        if today.count != tomorrow.count {
            var notEqual = false
            // Check if all elements at corresponding indices are equal
            for (element1, element2) in zip(today, tomorrow) {
                if element1.string != element2.string {
                    notEqual = true
                }
            }
            
            if notEqual {
                if Locale.isHebrewLocale() {
                        dateFormatterForZmanim.dateFormat = "H:mm"
                } else {
                        dateFormatterForZmanim.dateFormat = "h:mm aa"
                }
                
                let zmanimCalendar = ZmanimCalendar(location: GlobalStruct.geoLocation)
                zmanimCalendar.useElevation = GlobalStruct.useElevation
                zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate
                
                let alert = UIAlertController(title: "When did you start your meal?".localized(),
                                              message: "Did you start your meal before sunset?".localized()
                    .appending(" ")
                    .appending(dateFormatterForZmanim.string(from: zmanimCalendar.getElevationAdjustedSunset() ?? Date())), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { UIAlertAction in
                    self.openSiddur()
                }))
                alert.addAction(UIAlertAction(title: "No".localized(), style: .default, handler: { UIAlertAction in
                    GlobalStruct.chosenPrayer = "Birchat Hamazon+1"
                    self.openSiddur()
                }))
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { UIAlertAction in
                    self.viewDidAppear(false)//to reset titles
                }))
                present(alert, animated: true)
            }
        } else {
            self.openSiddur()
        }
    }
    func birchatMeEyinShalosh() {
        GlobalStruct.chosenPrayer = "Birchat MeEyin Shalosh"
        let today = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatMeeyinShaloshPrayers()
        GlobalStruct.jewishCalendar.forward()
        let tomorrow = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatMeeyinShaloshPrayers()
        GlobalStruct.jewishCalendar.back()//reset

        if today.count != tomorrow.count {
            var notEqual = false
            // Check if all elements at corresponding indices are equal
            for (element1, element2) in zip(today, tomorrow) {
                if element1.string != element2.string {
                    notEqual = true
                }
            }

            if notEqual {
                if Locale.isHebrewLocale() {
                        dateFormatterForZmanim.dateFormat = "H:mm"
                } else {
                        dateFormatterForZmanim.dateFormat = "h:mm aa"
                }

                let zmanimCalendar = ZmanimCalendar(location: GlobalStruct.geoLocation)
                zmanimCalendar.useElevation = GlobalStruct.useElevation
                zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate
                
                let alert = UIAlertController(title: "When did you start your meal?".localized(),
                                              message: "Did you start your meal before sunset?".localized()
                    .appending(" ")
                    .appending(dateFormatterForZmanim.string(from: zmanimCalendar.getElevationAdjustedSunset() ?? Date())), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { UIAlertAction in
                    self.openSiddur()
                }))
                alert.addAction(UIAlertAction(title: "No".localized(), style: .default, handler: { UIAlertAction in
                    GlobalStruct.chosenPrayer = "Birchat MeEyin Shalosh+1"
                    self.openSiddur()
                }))
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { UIAlertAction in
                    
                }))
                present(alert, animated: true)
            }
        } else {
            self.openSiddur()
        }
    }
    func tikkunChatzot() {
        if (GlobalStruct.jewishCalendar.is3Weeks()) {
            let isTachanunSaid = GlobalStruct.jewishCalendar.getTachanun() == "Tachanun only in the morning"
            || GlobalStruct.jewishCalendar.getTachanun() == "אומרים תחנון רק בבוקר"
            || GlobalStruct.jewishCalendar.getTachanun() == "אומרים תחנון"
            || GlobalStruct.jewishCalendar.getTachanun() == "There is Tachanun today"
            if (GlobalStruct.jewishCalendar.isDayTikkunChatzotSaid() && isTachanunSaid) {
                let alert = UIAlertController(title: "Do you want to say Tikkun Chatzot for the day?".localized(), message: "During the three weeks, some say a shorter Tikkun Chatzot after mid-day. Are you looking to say this version of Tikkun Chatzot?".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { UIAlertAction in
                    GlobalStruct.chosenPrayer = "Tikkun Chatzot (Day)"
                    self.openSiddur()
                }))
                alert.addAction(UIAlertAction(title: "No".localized(), style: .default, handler: { UIAlertAction in
                    GlobalStruct.chosenPrayer = "Tikkun Chatzot"
                    self.openSiddur()
                }))
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { UIAlertAction in
                    self.dismiss(animated: true)
                    self.viewDidAppear(false)//to reset titles
                }))
                present(alert, animated: true)
            } else {
                GlobalStruct.jewishCalendar.forward()
                if (GlobalStruct.jewishCalendar.isNightTikkunChatzotSaid()) {
                    GlobalStruct.chosenPrayer = "Tikkun Chatzot"
                    GlobalStruct.jewishCalendar.back()
                    self.openSiddur()
                } else {
                    GlobalStruct.jewishCalendar.back()
                    let alert = UIAlertController(title: "Tikkun Chatzot is not said today or tonight".localized(), message: "Tikkun Chatzot is not said today or tonight. Possible reasons for why it is not said: It is Friday/Friday night, No Tachanun is said today, Erev Rosh Chodesh AV, Rosh Chodesh, Rosh Hashana, Yom Kippur, Succot/Shemini Atzeret, Pesach, or Shavuot.".localized(), preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in }
                    alert.addAction(dismissAction)
                    present(alert, animated: true)
                }
            }
        } else {// Not three weeks
            GlobalStruct.jewishCalendar.forward()
            if (GlobalStruct.jewishCalendar.isNightTikkunChatzotSaid()) {
                GlobalStruct.chosenPrayer = "Tikkun Chatzot"
                GlobalStruct.jewishCalendar.back()
                self.openSiddur()
            } else {
                GlobalStruct.jewishCalendar.back()
                let alert = UIAlertController(title: "Tikkun Chatzot is not said tonight".localized(), message: "Tikkun Chatzot is not said tonight. Possible reasons for why it is not said: It is Friday night, Rosh Hashana, Yom Kippur, Succot/Shemini Atzeret, Pesach, or Shavuot.".localized(), preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in }
                alert.addAction(dismissAction)
                present(alert, animated: true)
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.backgroundColor = .secondarySystemBackground
        tableview.alwaysBounceVertical = false;
        tableview.dataSource = self
        tableview.delegate = self
        choices = [
            "morning": [],
            "night": [],
            "misc": []
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        var weekday = dateFormatter.string(from: GlobalStruct.jewishCalendar.workingDate)
        if Calendar.current.isDate(GlobalStruct.jewishCalendar.workingDate, inSameDayAs: Date()) {
            weekday = weekday.appending(" (Today)".localized())
        }
        let hebrewDateFormatter = HebrewDateFormatter()
        hebrewDateFormatter.hebrewFormat = Locale.isHebrewLocale()

        specialDayText = weekday
            .appending("\n")
            .appending(hebrewDateFormatter.format(jewishCalendar: GlobalStruct.jewishCalendar))
        
        if !GlobalStruct.jewishCalendar.getSpecialDay(addOmer: false).isEmpty {
            specialDayText = specialDayText
                .appending("\n")
                .appending(GlobalStruct.jewishCalendar.getSpecialDay(addOmer: false))
        }

        tonightText = weekday
            .appending(" " + "(After Sunset)".localized())
            .appending("\n")
            .appending(hebrewDateFormatter.format(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()))
        if !GlobalStruct.jewishCalendar.tomorrow().getSpecialDay(addOmer: false).isEmpty {
            tonightText = tonightText
                .appending("\n")
                .appending(GlobalStruct.jewishCalendar.tomorrow().getSpecialDay(addOmer: false))
        }

        if GlobalStruct.jewishCalendar.isSelichotSaid() {
            choices["morning"]?.append("סליחות")
        }
        choices["morning"]?.append("שחרית")
        if GlobalStruct.jewishCalendar.isRoshChodesh() || GlobalStruct.jewishCalendar.isCholHamoed() {
            choices["morning"]?.append("מוסף")
        }
        choices["morning"]?.append("מנחה")
        choices["night"]?.append("ערבית")
        if (GlobalStruct.jewishCalendar.tomorrow().isChanukah() || GlobalStruct.jewishCalendar.isChanukah() && GlobalStruct.jewishCalendar.getDayOfChanukah() != 8) {
            choices["night"]?.append("הדלקת נרות חנוכה")
        }
        if !GlobalStruct.jewishCalendar.hasCandleLighting() && GlobalStruct.jewishCalendar.isAssurBemelacha() || (GlobalStruct.jewishCalendar.isTishaBav() && GlobalStruct.jewishCalendar.getDayOfWeek() == 7 || GlobalStruct.jewishCalendar.getDayOfWeek() == 1) {
            choices["night"]?.append("הבדלה")
        }
        choices["night"]?.append("ק״ש שעל המיטה")
        choices[!GlobalStruct.jewishCalendar.is3Weeks() ? "night" : "misc"]?.append("תיקון חצות")
        choices["misc"]?.append("ברכת המזון")
        choices["misc"]?.append("ברכת מעין שלוש")
        if !GlobalStruct.jewishCalendar.getBirchatLevanaStatus().isEmpty {
            choices["misc"]?.append("ברכת הלבנה")
        }

        if GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.TU_BESHVAT {
            choices["misc"]?.append("Prayer for Etrog".localized())
        }

        if GlobalStruct.jewishCalendar.getUpcomingParshah() == JewishCalendar.Parsha.BESHALACH &&
            GlobalStruct.jewishCalendar.getDayOfWeek() == 3 {
            choices["misc"]?.append("Parshat Haman".localized())
        }
        tableview.reloadData()
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UITableViewCell()
        var content = headerCell.defaultContentConfiguration()
        content.textProperties.adjustsFontSizeToFitWidth = true
        content.textProperties.color = .secondaryLabel
        content.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)

        headerCell.backgroundColor = .secondarySystemBackground

        switch section {
        case 0:
            content.text = specialDayText
        case 1:
            content.text = tonightText
        default:
            content.text = "Misc.".localized()
        }

        headerCell.contentConfiguration = content
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tefilaEntry", for: indexPath)
        var content = cell.defaultContentConfiguration()
        cell.backgroundColor = .systemBackground
        content.textProperties.font = .systemFont(ofSize: 20, weight: .semibold)
        content.secondaryTextProperties.font = .systemFont(ofSize: 16, weight: .regular)
        
        switch indexPath.section {
        case 0:
            content.text = choices["morning"]?[indexPath.row]
        case 1:
            content.text = choices["night"]?[indexPath.row]
        default:
            content.text = choices["misc"]?[indexPath.row]
        }
        content.secondaryText = getSecondaryText(content.text!)
        
        if content.text == "סליחות" {
            zmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
            zmanimCalendar.useElevation = GlobalStruct.useElevation
            zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate
            var tzeit = Date()
            if defaults.bool(forKey: "LuachAmudeiHoraah") {
                tzeit = zmanimCalendar.getTzaisAmudeiHoraah() ?? Date()
            } else {
                tzeit = zmanimCalendar.getTzais13Point5MinutesZmanis() ?? Date();
            }
            if Date().compare(tzeit) == .orderedDescending && Date().compare(zmanimCalendar.getSolarMidnightIfSunTransitNil() ?? Date()) == .orderedAscending {
                    content.textProperties.color = .systemGray // Subtle gray for text
                    cell.alpha = 0.8 // Slightly dim entire cell
            }
        }
        if content.text == "תיקון חצות" {
            if (GlobalStruct.jewishCalendar.is3Weeks()) {
                let isTachanunSaid = GlobalStruct.jewishCalendar.getTachanun() == "Tachanun only in the morning"
                          || GlobalStruct.jewishCalendar.getTachanun() == "אומרים תחנון רק בבוקר"
                          || GlobalStruct.jewishCalendar.getTachanun() == "אומרים תחנון"
                          || GlobalStruct.jewishCalendar.getTachanun() == "There is Tachanun today"
                  if (!GlobalStruct.jewishCalendar.isDayTikkunChatzotSaid() || !isTachanunSaid) {
                      if (!GlobalStruct.jewishCalendar.tomorrow().isNightTikkunChatzotSaid()) {// i.e. both are not said
                          content.textProperties.color = .systemGray // Subtle gray for text
                          cell.alpha = 0.8 // Slightly dim entire cell
                      }
                  }
              } else {// not three weeks
                  if (!GlobalStruct.jewishCalendar.tomorrow().isNightTikkunChatzotSaid()) {
                      content.textProperties.color = .systemGray // Subtle gray for text
                      cell.alpha = 0.8 // Slightly dim entire cell
                  }
              }
        }
        
        if content.text == "הבדלה" {
            if (GlobalStruct.jewishCalendar.tomorrow().isTishaBav() && GlobalStruct.jewishCalendar.getDayOfWeek() == 7) {
                content.textProperties.color = .systemGray // Subtle gray for text
                cell.alpha = 0.8 // Slightly dim entire cell
            }
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var navigationArray:[String] = []
        switch indexPath.section {
        case 0:
            navigationArray = choices["morning"]!
        case 1:
            navigationArray = choices["night"]!
        default:
            navigationArray = choices["misc"]!
        }
        
        switch navigationArray[indexPath.row] {
        case "סליחות":
            GlobalStruct.chosenPrayer = "Selichot"
            openSiddur()
        case "שחרית":
            GlobalStruct.chosenPrayer = "Shacharit"
            openSiddur()
        case "מוסף":
            GlobalStruct.chosenPrayer = "Mussaf"
            openSiddur()
        case "מנחה":
            GlobalStruct.chosenPrayer = "Mincha"
            openSiddur()
        case "ערבית":
            GlobalStruct.chosenPrayer = "Arvit"
            openSiddur()
        case "ברכת המזון":
            birchatHamazon()
        case "ברכת הלבנה":
            GlobalStruct.chosenPrayer = "Birchat Halevana"
            openSiddur()
        case "תיקון חצות":
            tikkunChatzot()
        case "ק״ש שעל המיטה":
            GlobalStruct.chosenPrayer = "Kriat Shema SheAl Hamita"
            openSiddur()
        case "ברכת מעין שלוש":
            birchatMeEyinShalosh()
        case "הדלקת נרות חנוכה":
            GlobalStruct.chosenPrayer = "Hadlakat Neirot Chanuka"
            openSiddur()
        case "הבדלה":
            GlobalStruct.chosenPrayer = "Havdala"
            if (GlobalStruct.jewishCalendar.tomorrow().isTishaBav() && GlobalStruct.jewishCalendar.getDayOfWeek() == 7) {
                let alert = UIAlertController(title: "Havdalah is only said on a flame tonight.".localized(),
                                              message:"Havdalah will be completed after the fast.".localized().appending("\n\n").appending("בָּרוּךְ אַתָּה יְהֹוָה, אֱלֹהֵֽינוּ מֶֽלֶךְ הָעוֹלָם, בּוֹרֵא מְאוֹרֵי הָאֵשׁ:"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes (Jerusalem)".localized(), style: .default, handler: { UIAlertAction in
                    GlobalStruct.jewishCalendar.setIsMukafChoma(isMukafChoma: true)
                    GlobalStruct.jewishCalendar.setIsSafekMukafChoma(isSafekMukafChoma: false)
                    self.showFullScreenView("Siddur")
                }))
                present(alert, animated: true)
            } else {
                openSiddur()
            }
        default:
            if GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.TU_BESHVAT {
                openEtrogPrayerLink()
            } else {
                openParshatHamanPrayerLink()
            }
        }
    }
    
    func getSecondaryText(_ prayer:String) -> String? {
        switch prayer {
        case "סליחות":
            if GlobalStruct.jewishCalendar.isAseresYemeiTeshuva() {
                return "עשרת ימי תשובה"
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
            return entries.joined(separator: ", ")

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
            return entries.joined(separator: ", ")
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
            return entries.joined(separator: ", ")
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
            return entries.joined(separator: ", ")
        case "ברכת המזון":
            var entries:[String] = [
                GlobalStruct.jewishCalendar.isPurim() || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM ? "[על הניסים]" : "",
                GlobalStruct.jewishCalendar.isChanukah() ? "על הניסים" : "",
                GlobalStruct.jewishCalendar.getDayOfWeek() == 7 ? "[רצה]" : "",
                GlobalStruct.jewishCalendar.isRoshChodesh() || GlobalStruct.jewishCalendar.isCholHamoed() || GlobalStruct.jewishCalendar.isYomTovAssurBemelacha() ? "יעלה ויבוא" : ""
            ]
            entries = entries.filter { !$0.isEmpty }
            return entries.joined(separator: ", ")
        case "ק״ש שעל המיטה":
//            if Date().timeIntervalSince1970 > zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0 {
//                GlobalStruct.jewishCalendar.forward()
//            }
//            var tachanun =
//                GlobalStruct.jewishCalendar.getTachanun()
//                    .replacingOccurrences(of: "צדקתך", with: "")
//                    .replacingOccurrences(of: "לא אומרים תחנון", with: "")
//                    .replacingOccurrences(of: "אומרים תחנון רק בבוקר", with: "")
//                    .replacingOccurrences(of: "יש אומרים תחנון", with: "")
//                    .replacingOccurrences(of: "יש מדלגים תחנון במנחה", with: "")
//                    .replacingOccurrences(of: "אומרים תחנון", with: "")
//                
//                    .replacingOccurrences(of: "צדקתך", with: "")
//                    .replacingOccurrences(of: "No Tachanun today", with: "")
//                    .replacingOccurrences(of: "Tachanun only in the morning", with: "")
//                    .replacingOccurrences(of: "Some say Tachanun today", with: "")
//                    .replacingOccurrences(of: "Some skip Tachanun by mincha", with: "")
//                    .replacingOccurrences(of: "There is Tachanun today", with: "")
//
//            if Date().timeIntervalSince1970 > zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0 {
//                GlobalStruct.jewishCalendar.back()
//            }
            return nil
        case "Prayer for Etrog".localized():
            return "It is good to say this prayer today.".localized()
        case "Parshat Haman".localized():
            return "It is good to say this prayer today.".localized()
        default:
            return nil
        }
        
        return nil
    }

    func openEtrogPrayerLink() {
        if let openLink = URL(string: "https://elyahu41.github.io/Prayer%20for%20an%20Etrog.pdf") {
            if UIApplication.shared.canOpenURL(openLink) {
                UIApplication.shared.open(openLink, options: [:])
            }
        }
    }

    func openParshatHamanPrayerLink() {
        if let openLink = URL(string: "https://www.tefillos.com/Parshas-Haman-3.pdf") {
            if UIApplication.shared.canOpenURL(openLink) {
                UIApplication.shared.open(openLink, options: [:])
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {3}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return choices["morning"]?.count ?? 0
        case 1:
            return choices["night"]?.count ?? 0
        default:
            return choices["misc"]?.count ?? 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Calendar.current.isDate(lastTimeUserWasInApp, inSameDayAs: Date()) && lastTimeUserWasInApp.timeIntervalSinceNow < 7200 {//2 hours
            GlobalStruct.userChosenDate = Date()
            GlobalStruct.jewishCalendar.workingDate = GlobalStruct.userChosenDate
        }
        lastTimeUserWasInApp = Date()
        loadView()
        viewDidLoad()
    }
    
    func openSiddur() {
        if GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.PURIM || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM && !(GlobalStruct.chosenPrayer == "Birchat Halevana" || GlobalStruct.chosenPrayer.contains("Tikkun Chatzot") || GlobalStruct.chosenPrayer == "Kriat Shema SheAl Hamita") {// if the prayer is dependant on isMukafChoma, we ask the user
            let alert = UIAlertController(title: "Are you in a walled (Mukaf Choma) city?".localized(),
                                          message:"Are you located in a walled (Mukaf Choma) city from the time of Yehoshua Bin Nun?".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes (Jerusalem)".localized(), style: .default, handler: { UIAlertAction in
                GlobalStruct.jewishCalendar.setIsMukafChoma(isMukafChoma: true)
                GlobalStruct.jewishCalendar.setIsSafekMukafChoma(isSafekMukafChoma: false)
                self.showFullScreenView("Siddur")
            }))
            alert.addAction(UIAlertAction(title: "Doubt (Safek)".localized(), style: .default, handler: { UIAlertAction in
                GlobalStruct.jewishCalendar.setIsMukafChoma(isMukafChoma: false)
                GlobalStruct.jewishCalendar.setIsSafekMukafChoma(isSafekMukafChoma: true)
                self.showFullScreenView("Siddur")
            }))
            alert.addAction(UIAlertAction(title: "No".localized(), style: .default, handler: { UIAlertAction in
                // Undo any previous settings
                GlobalStruct.jewishCalendar.setIsMukafChoma(isMukafChoma: false)
                GlobalStruct.jewishCalendar.setIsSafekMukafChoma(isSafekMukafChoma: false)
                self.showFullScreenView("Siddur")
            }))
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { UIAlertAction in
                alert.dismiss(animated: false)
            }))
            showFullScreenView("Siddur")
        } else {
            showFullScreenView("Siddur")
        }
    }

    @objc func showDatePicker() {
        var alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .actionSheet)

        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .alert)
        }

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = GlobalStruct.userChosenDate
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(datePicker)

        // Add constraints to the date picker that pin it to the edges of the alert controller's view
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 32).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -32).isActive = true
        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 64).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -96).isActive = true

        let changeCalendarAction = UIAlertAction(title: "Switch Calendar".localized(), style: .default) { (_) in
            self.dismiss(animated: true)
            self.showHebrewDatePicker()
        }

        alertController.addAction(changeCalendarAction)

        let doneAction = UIAlertAction(title: "OK".localized(), style: .default) { (_) in
            self.loadView()
            self.viewDidLoad()
        }

        alertController.addAction(doneAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showHebrewDatePicker() {
        var alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .alert)
        }

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.calendar = Calendar(identifier: .hebrew)
        datePicker.locale = Locale(identifier: "he")
        datePicker.date = GlobalStruct.userChosenDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(datePicker)

        // Add constraints to the date picker that pin it to the edges of the alert controller's view
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 32).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -32).isActive = true
        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 64).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -96).isActive = true
        
        let changeCalendarAction = UIAlertAction(title: "Switch Calendar".localized(), style: .default) { (_) in
            self.dismiss(animated: true)
            self.showDatePicker()
        }

        alertController.addAction(changeCalendarAction)

        let doneAction = UIAlertAction(title: "OK".localized(), style: .default) { (_) in
            self.loadView()
            self.viewDidLoad()
        }

        alertController.addAction(doneAction)

        present(alertController, animated: true, completion: nil)
    }

    // Function to handle changes to the date picker value
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        GlobalStruct.userChosenDate = sender.date
        GlobalStruct.jewishCalendar.workingDate = GlobalStruct.userChosenDate
    }
}
