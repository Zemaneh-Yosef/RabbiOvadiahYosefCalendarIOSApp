//
//  SiddurChooserViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by User on 9/27/23.
//

import UIKit
import KosherSwift

class SiddurChooserViewController: UIViewController {
    
    let dateFormatterForZmanim = DateFormatter()
    var specialDayText = ""
    var tonightText = ""

    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func jerDirection(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "jerDirection") as! JerusalemDirectionViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true)
    }
    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    @IBOutlet weak var specialDay: UILabel!
    var tonight: UILabel = UILabel()
    var misc: UILabel = UILabel()
    @IBAction func selichot(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Selichot"
        selichot.setTitle("Loading...".localized(), for: .normal)
        setLoading()
        openSiddur()
    }
    @IBOutlet weak var selichot: UIButton!
    
    @IBAction func shacharit(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Shacharit"
        shacharit.setTitle("Loading...".localized(), for: .normal)
        setLoading()
        openSiddur()
    }
    @IBOutlet weak var shacharit: UIButton!
    
    @IBOutlet weak var mussaf: UIButton!
    @IBAction func mussaf(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Mussaf"
        mussaf.setTitle("Loading...".localized(), for: .normal)
        setLoading()
        openSiddur()
    }
    
    @IBAction func mincha(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Mincha"
        mincha.setTitle("Loading...".localized(), for: .normal)
        setLoading()
        openSiddur()
    }
    @IBOutlet weak var mincha: UIButton!
    
    @IBOutlet weak var neilah: UIButton!
    @IBAction func neilah(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Neilah"
        neilah.setTitle("Loading...".localized(), for: .normal)
        setLoading()
        openSiddur()
    }// future proof
    
    @IBAction func arvit(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Arvit"
        arvit.setTitle("Loading...".localized(), for: .normal)
        setLoading()
        openSiddur()
    }
    @IBOutlet weak var arvit: UIButton!
    
    @IBOutlet weak var birchatHamazon: UIButton!
    @IBAction func birchatHamazon(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Birchat Hamazon"
        birchatHamazon.setTitle("Loading...".localized(), for: .normal)
        setLoading()
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
                                              message: "Did you start your meal before sunset?".localized().appending(" ").appending(dateFormatterForZmanim.string(from: zmanimCalendar.getElevationAdjustedSunset() ?? Date())), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { UIAlertAction in
                    self.openSiddur()
                }))
                alert.addAction(UIAlertAction(title: "No".localized(), style: .default, handler: { UIAlertAction in
                    GlobalStruct.chosenPrayer = "Birchat Hamazon+1"
                    self.openSiddur()
                }))
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { UIAlertAction in
                    self.dismiss(animated: true)
                    self.viewDidAppear(false)//to reset titles
                }))
                present(alert, animated: true)
            }
        } else {
            self.openSiddur()
        }
    }
    @IBOutlet weak var birchatHalevana: UIButton!
    @IBAction func birchatHalevana(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Birchat Halevana"
        birchatHalevana.setTitle("Loading...".localized(), for: .normal)
        setLoading()
        openSiddur()
    }
    @IBAction func tikkunChatzot(_ sender: UIButton) {
        tikkunChatzot.setTitle("Loading...".localized(), for: .normal)
        setLoading()
        
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
    @IBOutlet weak var tikkunChatzot: UIButton!
    @IBAction func kriatShema(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Kriat Shema SheAl Hamita"
        kriatShema.setTitle("Loading...".localized(), for: .normal)
        setLoading()
        openSiddur()
    }
    @IBOutlet weak var kriatShema: UIButton!
    @IBOutlet weak var disclaimer: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: GlobalStruct.jewishCalendar.workingDate)
        let hebrewDateFormatter = HebrewDateFormatter()
        hebrewDateFormatter.hebrewFormat = Locale.isHebrewLocale()
        specialDay.text = weekday
            .appending("\n")
            .appending(hebrewDateFormatter.format(jewishCalendar: GlobalStruct.jewishCalendar))
        if !GlobalStruct.jewishCalendar.getSpecialDay(addOmer: false).isEmpty {
            specialDay.text = specialDay.text?
                .appending("\n")
                .appending(GlobalStruct.jewishCalendar.getSpecialDay(addOmer: false))
        }
        specialDayText = specialDay.text ?? ""
        
        tonight = UILabel()
        tonight.numberOfLines = 6
        tonight.textAlignment = .center
        GlobalStruct.jewishCalendar.forward()
        tonight.text = weekday
            .appending("\n")
            .appending("(After Sunset)".localized())
            .appending("\n")
            .appending(hebrewDateFormatter.format(jewishCalendar: GlobalStruct.jewishCalendar))
        if !GlobalStruct.jewishCalendar.getSpecialDay(addOmer: false).isEmpty {
            tonight.text = tonight.text?
                .appending("\n")
                .appending(GlobalStruct.jewishCalendar.getSpecialDay(addOmer: false))
        }
        tonightText = tonight.text ?? ""
        GlobalStruct.jewishCalendar.back()
        
        misc = UILabel()
        misc.textAlignment = .center
        misc.text = "Misc".localized()
        
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.alignment = .fill
        stackview.distribution = .fill
        stackview.spacing = 36
        stackview.translatesAutoresizingMaskIntoConstraints = false
        
        stackview.addArrangedSubview(specialDay)
        stackview.addArrangedSubview(selichot)
        stackview.addArrangedSubview(shacharit)
        stackview.addArrangedSubview(mussaf)
        stackview.addArrangedSubview(mincha)
        stackview.addArrangedSubview(neilah)
        stackview.addArrangedSubview(tonight)
        stackview.addArrangedSubview(arvit)
        stackview.addArrangedSubview(kriatShema)
        if !GlobalStruct.jewishCalendar.is3Weeks() {
            stackview.addArrangedSubview(tikkunChatzot)
        }
        stackview.addArrangedSubview(misc)
        if GlobalStruct.jewishCalendar.is3Weeks() {
            stackview.addArrangedSubview(tikkunChatzot)
        }
        stackview.addArrangedSubview(birchatHamazon)
        stackview.addArrangedSubview(birchatHalevana)
        stackview.addArrangedSubview(disclaimer)
                
        scrollView.addSubview(stackview)
        
        if GlobalStruct.jewishCalendar.isRoshChodesh() || GlobalStruct.jewishCalendar.isCholHamoed() || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.HOSHANA_RABBA {
            mussaf.isHidden = false
        }
        
        if GlobalStruct.jewishCalendar.isSelichotSaid() {
            selichot.isHidden = false
        }
        
//        if GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.YOM_KIPPUR {
//            neilah.isHidden = false
//        }
        
        if !GlobalStruct.jewishCalendar.getBirchatLevanaStatus().isEmpty {
            birchatHalevana.isHidden = false
        }
        
        if GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.SHUSHAN_PURIM {
            disclaimer.text = "Purim prayers will show on the 14th (yesterday)".localized()
        }
        
        if GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.TU_BESHVAT {
            disclaimer.text = "It is good to say this prayer on Tu'Beshvat:".localized().appending("\n\n").appending("Prayer for Etrog".localized())
            disclaimer.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(openEtrogPrayerLink))
            disclaimer.addGestureRecognizer(tap)
        }
        
        if GlobalStruct.jewishCalendar.getUpcomingParshah() == JewishCalendar.Parsha.BESHALACH &&
            GlobalStruct.jewishCalendar.getDayOfWeek() == 3 {
            disclaimer.text = "It is good to say this prayer today:".localized().appending("\n\n").appending("Parshat Haman".localized())
            disclaimer.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(openEtrogPrayerLink))
            disclaimer.addGestureRecognizer(tap)
        }
        
        if #available(iOS 15.0, *) {
            selichot.setTitleColor(.black, for: .normal)
            shacharit.setTitleColor(.black, for: .normal)
            mussaf.setTitleColor(.black, for: .normal)
            mincha.setTitleColor(.black, for: .normal)
            arvit.setTitleColor(.black, for: .normal)
            birchatHamazon.setTitleColor(.black, for: .normal)
            birchatHalevana.setTitleColor(.black, for: .normal)
            kriatShema.setTitleColor(.black, for: .normal)
            tikkunChatzot.setTitleColor(.black, for: .normal)
        }
        
        NSLayoutConstraint.activate([
            stackview.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackview.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackview.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackview.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            stackview.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }
    
    @objc func openEtrogPrayerLink() {
        if let openLink = URL(string: "https://elyahu41.github.io/Prayer%20for%20an%20Etrog.pdf") {
            if UIApplication.shared.canOpenURL(openLink) {
                UIApplication.shared.open(openLink, options: [:])
            }
        }
    }
    
    @objc func openParshatHamanPrayerLink() {
        if let openLink = URL(string: "https://www.tefillos.com/Parshas-Haman-3.pdf") {
            if UIApplication.shared.canOpenURL(openLink) {
                UIApplication.shared.open(openLink, options: [:])
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //reset all titles that were changed
        selichot.setTitle("סליחות", for: .normal)
        shacharit.setTitle("שחרית", for: .normal)
        mussaf.setTitle("מוסף", for: .normal)
        mincha.setTitle("מנחה", for: .normal)
        neilah.setTitle("נעילה", for: .normal)
        arvit.setTitle("ערבית", for: .normal)
        birchatHamazon.setTitle("ברכת המזון", for: .normal)
        birchatHalevana.setTitle("ברכת הלבנה", for: .normal)
        kriatShema.setTitle("ק״ש שעל המיטה", for: .normal)
        tikkunChatzot.setTitle("תיקון חצות", for: .normal)
        
        specialDay.text = specialDayText
        tonight.text = tonightText
        misc.text = "Misc".localized()
    }
    
    func setLoading() {
        specialDay.text = "Loading...".localized()
        tonight.text = "Loading...".localized()
        misc.text = "Loading...".localized()
    }
    
    func openSiddur() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "Siddur") as! SiddurViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true)
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
