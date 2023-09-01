//
//  ZmanimLanguageViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/18/23.
//

import UIKit

class ZmanimLanguageViewController: UIViewController {
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard

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
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "calendarChooser") as! CalendarViewController
            self.present(newViewController, animated: false, completion: nil)
        } else {
            let inIsraelView = super.presentingViewController?.presentingViewController!
            
            super.dismiss(animated: false) {//when this view is dismissed, dismiss the superview as well
                inIsraelView?.dismiss(animated: false)
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
