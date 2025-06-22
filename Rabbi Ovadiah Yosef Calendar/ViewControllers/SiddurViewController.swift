//
//  SiddurViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by User on 9/27/23.
//

import UIKit
import CoreLocation
import KosherSwift
import SnackBar
@preconcurrency import WebKit

class SiddurViewController: UIViewController, CLLocationManagerDelegate, WKNavigationDelegate {

    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var locationManager = CLLocationManager()
    var views: Array<UILabel> = []
    var compassImageView = UIImageView(image: UIImage(named: "compass"))
    let resetCSS = """
    /* Box sizing rules */
    *,
    *::before,
    *::after {
      box-sizing: border-box;
    }

    /* Prevent font size inflation */
    html {
      -moz-text-size-adjust: none;
      -webkit-text-size-adjust: none;
      text-size-adjust: none;
    }

    /* Remove default margin in favour of better control in authored CSS */
    body, h1, h2, h3, h4, p,
    figure, blockquote, dl, dd {
      margin-block-end: 0;
    }

    /* Remove list styles on ul, ol elements with a list role, which suggests default styling will be removed */
    ul[role='list'],
    ol[role='list'] {
      list-style: none;
    }

    /* Set core body defaults */
    body {
      min-height: 100vh;
      line-height: 1.5;
      margin: 0;
    }

    /* Set shorter line heights on headings and interactive elements */
    h1, h2, h3, h4,
    button, input, label {
      line-height: 1.1;
    }

    /* Balance text wrapping on headings */
    h1, h2,
    h3, h4 {
      text-wrap: balance;
    }

    /* A elements that don't have a class get default styles */
    a:not([class]) {
      text-decoration-skip-ink: auto;
      color: currentColor;
    }

    /* Make images easier to work with */
    img,
    picture {
      max-width: 100%;
      display: block;
    }

    /* Inherit fonts for inputs and buttons */
    input, button,
    textarea, select {
      font-family: inherit;
      font-size: inherit;
    }

    /* Make sure textareas without a rows attribute are not tiny */
    textarea:not([rows]) {
      min-height: 10em;
    }

    /* Anything that has been anchored to should have extra scroll margin */
    :target {
      scroll-margin-block: 5ex;
    }
    """

    public static var hideBackButton = false
    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBAction func slider(_ sender: UISlider, forEvent event: UIEvent) {
        defaults.set(sender.value, forKey: "textSize")
        let newSize = sender.value * 10
        webView.evaluateJavaScript("document.documentElement.style.setProperty('-webkit-text-size-adjust', '\(newSize)%');")
    }
    @IBOutlet weak var webView: WKWebView!
    @IBAction func justify(_ sender: UIButton) {
        defaults.set(!defaults.bool(forKey: "JustifyText"), forKey: "JustifyText")
        defaults.bool(forKey: "JustifyText") ? sender.setImage(.init(systemName: "text.justify"), for: .normal) : sender.setImage(.init(systemName: "text.alignright"), for: .normal)
        webView.evaluateJavaScript("document.documentElement.style.setProperty('text-align', '\(defaults.bool(forKey: "JustifyText") ? "justify" : "right")');")
    }
    @IBOutlet weak var dropdown: UIButton!
    @IBOutlet weak var justify: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if SiddurViewController.hideBackButton {
            back.isHidden = true
        }
        var listOfTexts = Array<HighlightString>()
        let zmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
        zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate

        var dropDownTitle: String = ""
        switch GlobalStruct.chosenPrayer {
        case "Selichot":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getSelichotPrayers(isAfterChatzot: Date().timeIntervalSince1970 > zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0
            && Date().timeIntervalSince1970 < (zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0) + 7200)
            dropDownTitle = "סליחות"
        case "Shacharit":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getShacharitPrayers()
            dropDownTitle = "שחרית"
        case "Mussaf":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getMusafPrayers()
            dropDownTitle = "מוסף"
        case "Mincha":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getMinchaPrayers()
            dropDownTitle = "מנחה"
        case "Arvit":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getArvitPrayers()
            dropDownTitle = "ערבית"
        case "Sefirat HaOmer":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getSefiratHaOmer()
            dropDownTitle = "ספירת העומר"
        case "Sefirat HaOmer+1":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getSefiratHaOmer()
            dropDownTitle = "ספירת העומר"
        case "Birchat Hamazon":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHamazonPrayers()
            dropDownTitle = "ברכת המזון"
        case "Birchat Hamazon+1":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getBirchatHamazonPrayers()
            dropDownTitle = "ברכת המזון"
        case "Tefilat HaDerech":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getTefilatHaderechPrayer()
            dropDownTitle = "תפלת הדרך"
        case "Birchat Halevana":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHalevanaPrayers()
            dropDownTitle = "ברכת הלבנה"
        case "Seder Siyum Masechet":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getSiyumMasechetPrayer(masechtas: GlobalStruct.siyumChoices)
            dropDownTitle = "סדר סיום מסכת"
        case "Tikkun Chatzot (Day)":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getTikkunChatzotPrayers(isForNight: false)
            dropDownTitle = "תיקון חצות"
        case "Tikkun Chatzot":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getTikkunChatzotPrayers(isForNight: true)
            dropDownTitle = "תיקון חצות"
        case "Kriat Shema SheAl Hamita":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getKriatShemaShealHamitaPrayers(isBeforeChatzot: Date().timeIntervalSince1970 < zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0)
            dropDownTitle = "ק״ש שעל המיטה"
        case "Birchat MeEyin Shalosh":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatMeeyinShaloshPrayers(allItems: GlobalStruct.meEyinShaloshChoices)
            dropDownTitle = "ברכת מעין שלוש"
        case "Birchat MeEyin Shalosh+1":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar.tomorrow()).getBirchatMeeyinShaloshPrayers(allItems: GlobalStruct.meEyinShaloshChoices)
            dropDownTitle = "ברכת מעין שלוש"
        case "Hadlakat Neirot Chanuka":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getHadlakatNeirotChanukaPrayers()
            dropDownTitle = "הדלקת נרות חנוכה"
        case "Havdala":
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getHavdalahPrayers()
            dropDownTitle = "הבדלה"
        default:
            listOfTexts = []
        }
        listOfTexts = appendUnicodeForDuplicates(in: listOfTexts)// to fix the issue of going to the same place for different categories with the same name
        dropdown.setTitle(dropDownTitle, for: .normal)
        dropdown.showsMenuAsPrimaryAction = true
        dropdown.semanticContentAttribute = .forceLeftToRight
        var categories:[UIAction] = []

        let fontString = """
        @font-face {
            font-family: "guttman-mantova";
            src: url('Guttman Mantova.ttf') format('truetype');
        }
        
        @font-face {
            font-family: "keren";
            src: url('Guttman Keren.ttf') format('truetype');
        }
        
        @font-face {
            font-family: "taamey";
            src: url('Taamey D.ttf') format('truetype');
        }
        """
        webView.navigationDelegate = self
        if defaults.float(forKey: "textSize") == 0.0 {
            slider.value = 16
            defaults.set(16, forKey: "textSize")
        }
        var catsFound = false
        var fontFamily = ""
        if defaults.string(forKey: "fontName") == nil {
            defaults.set("Guttman Keren", forKey: "fontName")
        }
        switch defaults.string(forKey: "fontName") {
        case "Guttman Keren" :
            fontFamily = "keren"
        case "Taamey D" :
            fontFamily = "taamey"
        default:
            fontFamily = "none"
        }

        var webstring = "<!DOCTYPE html><html dir=rtl><body><meta name='viewport' content='width=device-width, initial-scale=1' /><style>:root{overflow-x: hidden; color-scheme: light dark; -webkit-text-size-adjust: \(defaults.float(forKey: "textSize") * 10)%; text-align: \(defaults.bool(forKey: "JustifyText") ? "justify" : "right"); font-family: '\(fontFamily)'; }\(resetCSS)\(fontString)p{padding-top: 0; padding-right: .4rem; padding-left: .4rem; padding-bottom: 1rem; margin: 0;} @media (prefers-color-scheme: dark) { #kefiraLight { display: none; }  .highlight { background: #DAA520; color: black; display: block; } details { background: \(UIColor.darkGray.toHex()); } } @media(prefers-color-scheme: light) { #kefiraShadow { display: none; } .highlight { background: #CCE6FF; } details { background: \(UIColor.lightGray.toHex())} }#compass { transform: rotate(var(--deg, 0deg)); position: absolute; width: 100vw; } .compassContainer { aspect-ratio: 1/1; position: relative; overflow: hidden; } details { margin: 0; margin-bottom: .4rem; padding: .4rem; }</style>"
        for text in listOfTexts {
            let formattedString = text.string.replacingOccurrences(of: "\n", with: "<br>")
            if text.string == "(Use this compass to help you find which direction South is in. Do not hold your phone straight up or place it on a table, hold it normally.) " +
                "עזר לך למצוא את הכיוון הדרומי באמצעות המצפן הזה. אל תחזיק את הטלפון שלך בצורה ישרה למעלה או תנה אותו על שולחן, תחזיק אותו בצורה רגילה.:" {
                locationManager.delegate = self

                // Start location services to get the true heading.
                locationManager.distanceFilter = 1000
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                locationManager.startUpdatingLocation()

                // Start heading updating.
                if CLLocationManager.headingAvailable() {
                    locationManager.headingFilter = 1
                    locationManager.startUpdatingHeading()
                }
                webstring += "<p class='highlight'>" + formattedString + "</p>"
                webstring += "<div class='highlight compassContainer'><img id='compass' src='compass.png' /></div>"
            } else if text.string == "[break here]" {
                webstring += "<hr>"
            } else if text.isCategory {
                catsFound = true
                webstring += "<p id='\(text.string)' style='padding: .25rem; font-family: guttman-mantova; text-align: center;'>" + formattedString + "</p>"
                categories.append(UIAction(title: text.string, identifier: nil, state: .mixed) { _ in
                    self.webView.evaluateJavaScript("document.getElementById('\(text.string)').scrollIntoView()")
                })
            } else if text.string == "Mussaf is said here, press here to go to Mussaf" || text.string == "מוסף אומרים כאן, לחץ כאן כדי להמשיך למוסף" || text.string == "Open Sefaria Siddur/פתח את סידור ספריה" {
                webstring += "<a href='" + (text.string == "Open Sefaria Siddur/פתח את סידור ספריה" ? "iosapp://sefaria" : "iosapp://musaf") + "' class='highlight'>" + text.string + "</a>"
            } else if text.shouldBeHighlighted {
                webstring += "<p class='highlight'>" + formattedString + "</p>"
            } else if text.isInfo {
                webstring += formattedString
            } else {
                webstring += "<p>" + formattedString + "</p>"
                if text.string.hasSuffix(SiddurMaker.menorah) {
                    webstring += "<img id='kefiraLight' src='menora.svg' style='width: 100%;' /><img id='kefiraShadow' src='menora-shadow.svg' style='width: 100%;' />"
                }
            }
        }
        dropdown.menu = UIMenu(title: "", options: .displayInline, children: categories)
        if !catsFound {
            dropdown.isEnabled = false
            dropdown.imageView?.isHidden = true
        }
        let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
        webView.scrollView.alwaysBounceHorizontal = false
        webView.loadHTMLString(webstring, baseURL: baseURL)
        slider.value = defaults.float(forKey: "textSize")
        defaults.bool(forKey: "JustifyText") ? justify.setImage(.init(systemName: "text.justify"), for: .normal) : justify.setImage(.init(systemName: "text.alignright"), for: .normal)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        let urlAsString = navigationAction.request.url?.absoluteString.lowercased()

        if urlAsString?.range(of: "iosapp://musaf") != nil {
            tapFunctionMussaf()
        } else if urlAsString?.range(of: "iosapp://sefaria") != nil {
            tapFunctionSefaria()
        }
     }
    
    func tapFunctionMussaf() {
        GlobalStruct.chosenPrayer = "Mussaf"
        super.dismiss(animated: false)
        SiddurViewController.hideBackButton = false
        showFullScreenView("Siddur")
    }
    
    func tapFunctionSefaria() {
        if let url = URL(string: "https://www.sefaria.org/Siddur_Edot_HaMizrach") {
                UIApplication.shared.open(url)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

        if newHeading.headingAccuracy < 0 {
            return
        }

        // Get the heading(direction) in degrees
        let heading: CLLocationDirection = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading) * -1
        webView.evaluateJavaScript("document.documentElement.style.setProperty('--deg', '\(heading)deg');")

//       var strDirection = String()
//        if(heading > 23 && heading <= 67){
//            strDirection = "North East";
//        } else if(heading > 68 && heading <= 112){
//            strDirection = "East";
//        } else if(heading > 113 && heading <= 167){
//            strDirection = "South East";
//        } else if(heading > 168 && heading <= 202){
//            strDirection = "South";
//        } else if(heading > 203 && heading <= 247){
//            strDirection = "South West";
//        } else if(heading > 248 && heading <= 293){
//            strDirection = "West";
//        } else if(heading > 294 && heading <= 337){
//            strDirection = "North West";
//        } else if(heading >= 338 || heading <= 22){
//            strDirection = "North";
//        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
