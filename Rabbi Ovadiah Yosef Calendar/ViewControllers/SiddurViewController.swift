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

class SiddurViewController: UIViewController, CLLocationManagerDelegate {
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var locationManager = CLLocationManager()
    var views: Array<UILabel> = []
    var compassImageView = UIImageView(image: UIImage(named: "compass"))
    let _acceptableCharacters = "0123456789."

    @IBAction func changeTextSize(_ sender: UIButton) {
        let alert = UIAlertController(title: "Set text size".localized(),
                                      message: "You can set the size of your text in the text box below. The default size is 16.".localized(), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Size (12.0 - 78.0)".localized()
        }
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: defaults.bool(forKey: "JustifyText") ? "Right Align Text".localized() : "Justify".localized(), style: .default, handler: { [self] (_) in
            defaults.set(!defaults.bool(forKey: "JustifyText"), forKey: "JustifyText")
            SnackBar(contextView: view, message: "Please close and open the siddur.".localized(), duration: SnackBar.Duration.lengthShort).show()
        }))
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { [self, weak alert] (_) in
            let textField = alert?.textFields![0].text
            //if text is empty, display a message notifying the user:
            if textField == nil || textField == "" || !CharacterSet(charactersIn: _acceptableCharacters).isSuperset(of: CharacterSet(charactersIn: textField ?? "")) {
                let alert = UIAlertController(title: "Error".localized(), message: "Please enter a valid number.".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: {_ in
                    alert.dismiss(animated: true) // just dismiss the dialog
                }))
                self.present(alert, animated: true)
                return
            } else {
                var newSize = Float(textField ?? "16")
                if newSize! <= 11 {
                    newSize = 12.0
                }
                if newSize! >= 78.0 {
                    newSize = 78
                }
                print(newSize!)
                self.defaults.set(newSize, forKey: "textSize")
                for l in views {
                    l.font = .boldSystemFont(ofSize: CGFloat(newSize ?? 16))
                }
            }
        }))
        present(alert, animated: true)
    }
    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    @IBOutlet weak var stackviewContainer: UIStackView!
    //    @IBOutlet weak var slider: UISlider!
//    @IBAction func slider(_ sender: UISlider, forEvent event: UIEvent) {
//        sender.isEnabled = false
//        let newSize = sender.value
//        print(newSize)
//        defaults.set(newSize, forKey: "textSize")
//        for l in views {
//            l.font = .boldSystemFont(ofSize: CGFloat(newSize) + 16)
//        }
//        sender.isEnabled = true
//    }
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categories: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var listOfTexts = Array<HighlightString>()
        let zmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
        zmanimCalendar.workingDate = GlobalStruct.jewishCalendar.workingDate

        if GlobalStruct.chosenPrayer == "Selichot" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getSelichotPrayers(isAfterChatzot: Date().timeIntervalSince1970 > zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0
            && Date().timeIntervalSince1970 < (zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0) + 7200)
        }
        if GlobalStruct.chosenPrayer == "Shacharit" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getShacharitPrayers()
        }
        if GlobalStruct.chosenPrayer == "Mussaf" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getMusafPrayers()
        }
        if GlobalStruct.chosenPrayer == "Mincha" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getMinchaPrayers()
        }
        if GlobalStruct.chosenPrayer == "Neilah" {//will never show, but future proof it
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getMusafPrayers()
        }
        if GlobalStruct.chosenPrayer == "Arvit" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getArvitPrayers()
        }
        if GlobalStruct.chosenPrayer == "Birchat Hamazon" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHamazonPrayers()
        }
        if GlobalStruct.chosenPrayer == "Birchat Hamazon+1" {
            GlobalStruct.jewishCalendar.forward()
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHamazonPrayers()
            GlobalStruct.jewishCalendar.back()
        }
        if GlobalStruct.chosenPrayer == "Birchat Halevana" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatHalevanaPrayers()
        }
        if GlobalStruct.chosenPrayer == "Tikkun Chatzot (Day)" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getTikkunChatzotPrayers(isForNight: false)
        }
        if GlobalStruct.chosenPrayer == "Tikkun Chatzot" {
            GlobalStruct.jewishCalendar.forward()
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getTikkunChatzotPrayers(isForNight: true)
            GlobalStruct.jewishCalendar.back()
        }
        if GlobalStruct.chosenPrayer == "Kriat Shema SheAl Hamita" {
            GlobalStruct.jewishCalendar.forward()
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getKriatShemaShealHamitaPrayers(isBeforeChatzot: Date().timeIntervalSince1970 < zmanimCalendar.getSolarMidnightIfSunTransitNil()?.timeIntervalSince1970 ?? 0)
            GlobalStruct.jewishCalendar.back()
        }
        if GlobalStruct.chosenPrayer == "Birchat MeEyin Shalosh" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatMeeyinShaloshPrayers()
        }
        if GlobalStruct.chosenPrayer == "Birchat MeEyin Shalosh+1" {
            GlobalStruct.jewishCalendar.forward()
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getBirchatMeeyinShaloshPrayers()
            GlobalStruct.jewishCalendar.back()
        }
        listOfTexts = appendUnicodeForDuplicates(in: listOfTexts)// to fix the issue of going to the same place for different categories with the same name
        
        let stackviewH = UIStackView()
        stackviewH.axis = .horizontal
        stackviewH.spacing = 2
        stackviewH.translatesAutoresizingMaskIntoConstraints = false
        categories.translatesAutoresizingMaskIntoConstraints = false
        categories.showsHorizontalScrollIndicator = true
        categories.showsVerticalScrollIndicator = false
        categories.addSubview(stackviewH)
        
        for text in listOfTexts {
            if text.isCategory {
                let label = UILabel()
                label.numberOfLines = 0
                label.textAlignment = .center
                label.text = text.string
                label.font = .boldSystemFont(ofSize: 18)
                let tap = UITapGestureRecognizerWithParam(parameter: label, target: self, action: #selector(tapFunctionCategory))
                tap.parameter = label
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(tap)
                stackviewH.addArrangedSubview(label)
            }
        }
        
        NSLayoutConstraint.activate([
            stackviewH.topAnchor.constraint(equalTo: categories.contentLayoutGuide.topAnchor),
            stackviewH.leadingAnchor.constraint(equalTo: categories.contentLayoutGuide.leadingAnchor),
            stackviewH.trailingAnchor.constraint(equalTo: categories.contentLayoutGuide.trailingAnchor),
            stackviewH.bottomAnchor.constraint(equalTo: categories.contentLayoutGuide.bottomAnchor),
            
            stackviewH.trailingAnchor.constraint(greaterThanOrEqualTo: categories.frameLayoutGuide.trailingAnchor)
        ])
        
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.spacing = 0
        stackview.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackview)
        
        //slider.setValue(defaults.float(forKey: "textSize"), animated: true)
                
        for text in listOfTexts {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = defaults.bool(forKey: "JustifyText") ? .justified : .right
            label.text = text.string
            if defaults.bool(forKey: "JustifyText") {
                let text: NSMutableAttributedString = NSMutableAttributedString(string: text.string)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .justified
                paragraphStyle.baseWritingDirection = .rightToLeft
                paragraphStyle.lineBreakMode = .byWordWrapping
                text.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.length))
                label.attributedText = text
            }

            var textSize = CGFloat(defaults.float(forKey: "textSize"))
            if textSize == 0 {
                textSize = 16
            }
            label.font = .boldSystemFont(ofSize: textSize)
            if text.shouldBeHighlighted {
                label.text = "\n".appending(text.string)
                label.textColor = .black
                label.backgroundColor = .yellow
            }
            if text.string == "[break here]" {
                label.text = ""
                                
                let lineView = UIView(frame: CGRect(x: 0, y: 10, width: self.view.frame.width, height: 2))
                lineView.backgroundColor = label.textColor
                label.addSubview(lineView)
            }
            if text.string == "Open Sefaria Siddur/פתח את סידור ספריה" {
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunctionSefaria))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(tap)
            }
            if text.string == "Mussaf is said here, press here to go to Mussaf" || text.string == "מוסף אומרים כאן, לחץ כאן כדי להמשיך למוסף" {
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunctionMussaf))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(tap)
            }
            label.text! += "\n"
            views.append(label)
            stackview.addArrangedSubview(label)
            if text.string == "(Use this compass to help you find which direction South is in. Do not hold your phone straight up or place it on a table, hold it normally.) " +
                "עזר לך למצוא את הכיוון הדרומי באמצעות המצפן הזה. אל תחזיק את הטלפון שלך בצורה ישרה למעלה או תנה אותו על שולחן, תחזיק אותו בצורה רגילה.:" {
                compassImageView.backgroundColor = UIColor.black
                compassImageView.contentMode = .scaleAspectFit // Adjust the content mode as needed
                stackview.addArrangedSubview(compassImageView)
                locationManager.delegate = self
                
                // Start location services to get the true heading.
                locationManager.distanceFilter = 1000
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                locationManager.startUpdatingLocation()
                
                //Start heading updating.
                if CLLocationManager.headingAvailable() {
                    locationManager.headingFilter = 1
                    locationManager.startUpdatingHeading()
                }
            }
            if text.string.hasSuffix("לַמְנַצֵּ֥חַ בִּנְגִינֹ֗ת מִזְמ֥וֹר שִֽׁיר׃ אֱֽלֹהִ֗ים יְחׇנֵּ֥נוּ וִיבָרְכֵ֑נוּ יָ֤אֵֽר פָּנָ֖יו אִתָּ֣נוּ סֶֽלָה׃ לָדַ֣עַת בָּאָ֣רֶץ דַּרְכֶּ֑ךָ בְּכׇל־גּ֝וֹיִ֗ם יְשׁוּעָתֶֽךָ׃ יוֹד֖וּךָ עַמִּ֥ים ׀ אֱלֹהִ֑ים י֝וֹד֗וּךָ עַמִּ֥ים כֻּלָּֽם׃ יִ֥שְׂמְח֥וּ וִירַנְּנ֗וּ לְאֻ֫מִּ֥ים כִּֽי־תִשְׁפֹּ֣ט עַמִּ֣ים מִישֹׁ֑ר וּלְאֻמִּ֓ים ׀ בָּאָ֖רֶץ תַּנְחֵ֣ם סֶֽלָה׃ יוֹד֖וּךָ עַמִּ֥ים ׀ אֱלֹהִ֑ים י֝וֹד֗וּךָ עַמִּ֥ים כֻּלָּֽם׃ אֶ֭רֶץ נָתְנָ֣ה יְבוּלָ֑הּ יְ֝בָרְכֵ֗נוּ אֱלֹהִ֥ים אֱלֹהֵֽינוּ׃ יְבָרְכֵ֥נוּ אֱלֹהִ֑ים וְיִֽירְא֥וּ א֝וֹת֗וֹ כׇּל־אַפְסֵי־אָֽרֶץ׃") {
                let menorahImageView = UIImageView(image: UIImage(named: "menorah"))
                menorahImageView.contentMode = .scaleAspectFit // Adjust the content mode as needed
                stackview.addArrangedSubview(menorahImageView)
            }
        }
        
        NSLayoutConstraint.activate([
            stackview.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackview.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackview.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackview.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            stackview.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
        
        if stackviewH.arrangedSubviews.isEmpty {
            categories.isHidden = true
            NSLayoutConstraint.activate([scrollView.topAnchor.constraint(equalTo: stackviewContainer.topAnchor)])
        }
    }
    
    @objc func tapFunctionCategory(_ sender: UITapGestureRecognizerWithParam) {
        for view in views {
            if view.text?.replacingOccurrences(of: "\n", with: "") == sender.parameter.text {
                let labelFrameInScrollView = view.convert(view.bounds, to: scrollView)
                scrollView.scrollRectToVisible(labelFrameInScrollView, animated: false)
                break
            }
        }
    }
    
    @IBAction func tapFunctionMussaf(sender: UITapGestureRecognizer) {
        GlobalStruct.chosenPrayer = "Mussaf"
        super.dismiss(animated: false)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "Siddur") as! SiddurViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.presentingViewController?.present(newViewController, animated: false)
    }
    
    @IBAction func tapFunctionSefaria(sender: UITapGestureRecognizer) {
        if let url = URL(string: "https://www.sefaria.org/Siddur_Edot_HaMizrach") {
                UIApplication.shared.open(url)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

        if newHeading.headingAccuracy < 0 {
            return
        }

        // Get the heading(direction)
        let heading: CLLocationDirection = ((newHeading.trueHeading > 0) ?
            newHeading.trueHeading : newHeading.magneticHeading);
        UIView.animate(withDuration: 0.5) {
            let angle = CGFloat(heading) * .pi / 180 // convert from degrees to radians
            self.compassImageView.transform = CGAffineTransform(rotationAngle: angle) // rotate the picture
        }

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

class UITapGestureRecognizerWithParam: UITapGestureRecognizer {
    var parameter: UILabel
    
    init(parameter: UILabel, target: Any?, action: Selector?) {
        self.parameter = parameter
        super.init(target: target, action: action)
    }
}

