//
//  SiddurChooserViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by User on 9/27/23.
//

import UIKit
import KosherSwift

class SiddurChooserViewController: UIViewController {

    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    @IBOutlet weak var specialDay: UILabel!
    @IBAction func selichot(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Selichot"
        selichot.setTitle("Loading...".localized(), for: .normal)
        openSiddur()
    }
    @IBOutlet weak var selichot: UIButton!
    
    @IBAction func shacharit(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Shacharit"
        shacharit.setTitle("Loading...".localized(), for: .normal)
        openSiddur()
    }
    @IBOutlet weak var shacharit: UIButton!
    
    @IBOutlet weak var mussaf: UIButton!
    @IBAction func mussaf(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Mussaf"
        mussaf.setTitle("Loading...".localized(), for: .normal)
        openSiddur()
    }
    
    @IBAction func mincha(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Mincha"
        mincha.setTitle("Loading...".localized(), for: .normal)
        openSiddur()
    }
    @IBOutlet weak var mincha: UIButton!
    
    @IBOutlet weak var neilah: UIButton!
    @IBAction func neilah(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Neilah"
        neilah.setTitle("Loading...".localized(), for: .normal)
        openSiddur()
    }// future proof
    
    @IBAction func arvit(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Arvit"
        arvit.setTitle("Loading...".localized(), for: .normal)
        openSiddur()
    }
    @IBOutlet weak var arvit: UIButton!
    
    @IBOutlet weak var birchatHamazon: UIButton!
    @IBAction func birchatHamazon(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Birchat Hamazon"
        birchatHamazon.setTitle("Loading...".localized(), for: .normal)
        let alert = UIAlertController(title: "When did you start your meal?".localized(),
                                              message: "Did you start your meal during the day?".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { UIAlertAction in
            GlobalStruct.chosenPrayer = "Birchat Hamazon+1"
            self.openSiddur()
        }))
        alert.addAction(UIAlertAction(title: "No".localized(), style: .default, handler: { UIAlertAction in
            self.openSiddur()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { UIAlertAction in
            self.dismiss(animated: true)
            self.viewDidAppear(false)//to reset titles
        }))
        present(alert, animated: true)
    }
    @IBOutlet weak var disclaimer: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GlobalStruct.jewishCalendar.isRoshChodesh() || GlobalStruct.jewishCalendar.isCholHamoed() || GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.HOSHANA_RABBA {
            mussaf.isHidden = false
        }
        
        if GlobalStruct.jewishCalendar.isSelichotSaid() {
            selichot.isHidden = false
        }
        
//        if GlobalStruct.jewishCalendar.getYomTovIndex() == JewishCalendar.YOM_KIPPUR {
//            neilah.isHidden = false
//        }
        
        if !GlobalStruct.jewishCalendar.getSpecialDay(addOmer: false).isEmpty {
            specialDay.text = GlobalStruct.jewishCalendar.getSpecialDay(addOmer: false)
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
            selichot.configuration = .filled()
            selichot.configuration?.background.backgroundColor = .init(named: "Gold")
            selichot.setTitleColor(.black, for: .normal)
            selichot.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)

            shacharit.configuration = .filled()
            shacharit.configuration?.background.backgroundColor = .init(named: "Gold")
            shacharit.setTitleColor(.black, for: .normal)
            shacharit.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
            
            mussaf.configuration = .filled()
            mussaf.configuration?.background.backgroundColor = .init(named: "Gold")
            mussaf.setTitleColor(.black, for: .normal)
            mussaf.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
            
            mincha.configuration = .filled()
            mincha.configuration?.background.backgroundColor = .init(named: "Gold")
            mincha.setTitleColor(.black, for: .normal)
            mincha.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
            
            arvit.configuration = .filled()
            arvit.configuration?.background.backgroundColor = .init(named: "Gold")
            arvit.setTitleColor(.black, for: .normal)
            arvit.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
            
            birchatHamazon.configuration = .filled()
            birchatHamazon.configuration?.background.backgroundColor = .init(named: "Gold")
            birchatHamazon.setTitleColor(.black, for: .normal)
            birchatHamazon.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
        }
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
