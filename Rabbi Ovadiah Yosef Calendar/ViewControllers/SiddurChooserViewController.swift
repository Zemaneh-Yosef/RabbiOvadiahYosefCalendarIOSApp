//
//  SiddurChooserViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by User on 9/27/23.
//

import UIKit
import KosherCocoa

class SiddurChooserViewController: UIViewController {

    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    @IBAction func selichot(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Selichot"
        openSiddur()
    }
    @IBOutlet weak var selichot: UIButton!
    
    @IBAction func shacharit(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Shacharit"
        openSiddur()
    }
    @IBOutlet weak var shacharit: UIButton!
    
    @IBOutlet weak var mussaf: UIButton!
    @IBAction func mussaf(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Mussaf"
        openSiddur()
    }
    
    @IBAction func mincha(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Mincha"
        openSiddur()
    }
    @IBOutlet weak var mincha: UIButton!
    
    @IBOutlet weak var neilah: UIButton!
    @IBAction func neilah(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Neilah"
        openSiddur()
    }// future proof
    
    @IBAction func arvit(_ sender: UIButton) {
        GlobalStruct.chosenPrayer = "Arvit"
        openSiddur()
    }
    @IBOutlet weak var arvit: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GlobalStruct.jewishCalendar.isRoshChodesh() || GlobalStruct.jewishCalendar.isCholHamoed() || GlobalStruct.jewishCalendar.yomTovIndex() == kHoshanaRabba.rawValue {
            mussaf.isHidden = false
        }
        
        if GlobalStruct.jewishCalendar.isSelichotSaid() {
            selichot.isHidden = false
        }
        
//        if GlobalStruct.jewishCalendar.yomTovIndex() == kYomKippur.rawValue {
//            neilah.isHidden = false
//        }
        
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
        }
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
