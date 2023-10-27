//
//  SiddurViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by User on 9/27/23.
//

import UIKit
import CoreLocation

class SiddurViewController: UIViewController, CLLocationManagerDelegate {
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var locationManager = CLLocationManager()
    var views: Array<UILabel> = []
    var compassImageView = UIImageView(image: UIImage(named: "compass"))

    @IBOutlet weak var slider: UISlider!
    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    
    @IBAction func slider(_ sender: UISlider, forEvent event: UIEvent) {
        let newSize = sender.value
        defaults.set(newSize, forKey: "textSize")
        for l in views {
            l.font = .boldSystemFont(ofSize: CGFloat(newSize) + 16)
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var listOfTexts = Array<HighlightString>()
        
        if GlobalStruct.chosenPrayer == "Selichot" {
            listOfTexts = SiddurMaker(jewishCalendar: GlobalStruct.jewishCalendar).getSelichotPrayers()
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
        
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.spacing = 0
                
        stackview.translatesAutoresizingMaskIntoConstraints = false
                
        scrollView.addSubview(stackview)
        
        slider.setValue(defaults.float(forKey: "textSize"), animated: true)
                
        for text in listOfTexts {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .right
            label.text = text.string
            let textSize = CGFloat(defaults.float(forKey: "textSize"))
            label.font = .boldSystemFont(ofSize: textSize + 16)
            if text.shouldBeHighlighted {
                label.text = "\n".appending(text.string)
                label.textColor = .black
                label.backgroundColor = .yellow
            }
            if text.string == "Mussaf is said here, press here to go to Mussaf" {
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
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
                    locationManager.headingFilter = 5
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
    }
    
    @IBAction func tapFunction(sender: UITapGestureRecognizer) {
        GlobalStruct.chosenPrayer = "Mussaf"
        super.dismiss(animated: false)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "Siddur") as! SiddurViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.presentingViewController?.present(newViewController, animated: false)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
