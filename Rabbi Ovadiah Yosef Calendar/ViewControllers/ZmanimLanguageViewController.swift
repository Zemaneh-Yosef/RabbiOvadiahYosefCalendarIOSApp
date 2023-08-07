//
//  ZmanimLanguageViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/18/23.
//

import UIKit

class ZmanimLanguageViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    @IBAction func hebrew(_ sender: UIButton) {
        defaults.set(true, forKey: "isZmanimInHebrew")
        defaults.set(false, forKey: "isZmanimEnglishTranslated")
        showCalendarChooserView()
    }
    @IBAction func English(_ sender: UIButton) {
        defaults.set(false, forKey: "isZmanimInHebrew")
        defaults.set(false, forKey: "isZmanimEnglishTranslated")
        showCalendarChooserView()
    }
    @IBAction func translatedEnglish(_ sender: UIButton) {
        defaults.set(false, forKey: "isZmanimInHebrew")
        defaults.set(true, forKey: "isZmanimEnglishTranslated")
        showCalendarChooserView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func showCalendarChooserView() {
        if !defaults.bool(forKey: "inIsrael") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "calendarChooser") as! CalendarViewController
            self.present(newViewController, animated: true, completion: nil)
        } else {
            let inIsraelView = super.presentingViewController?.presentingViewController!
            
            super.dismiss(animated: true) {//when this view is dismissed, dismiss the superview as well
                inIsraelView?.dismiss(animated: true)
            }
        }
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
