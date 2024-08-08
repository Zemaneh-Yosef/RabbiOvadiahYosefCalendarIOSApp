//
//  InIsraelViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/18/23.
//

import UIKit

class InIsraelViewController: UIViewController {
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard

    @IBOutlet weak var no: UIButton!
    @IBOutlet weak var yes: UIButton!
    @IBAction func yesButton(_ sender: UIButton) {
        defaults.setValue(true, forKey: "inIsrael")
        presentZmanimLanguages(inIsrael: true)
    }
    @IBAction func noButton(_ sender: UIButton) {
        defaults.setValue(false, forKey: "inIsrael")
        presentZmanimLanguages(inIsrael: false)
    }
    func presentZmanimLanguages(inIsrael:Bool) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var newViewController: UIViewController
        if Locale.isHebrewLocale() {// if person speaks hebrew, skip language chooser
            defaults.setValue(true, forKey: "isZmanimInHebrew")
            defaults.setValue(false, forKey: "isZmanimEnglishTranslated")
            if inIsrael {// if in israel, skip calendar chooser as well
                if defaults.bool(forKey: "isSetup") {
                    self.dismiss(animated: false)
                } else {// user has never setup the app before, needs location details
                    newViewController = storyboard.instantiateViewController(withIdentifier: "search_a_place") as! GetUserLocationViewController
                    self.present(newViewController, animated: false)
                }
            } else {// Not in Israel
                if defaults.bool(forKey: "isSetup") {
                    newViewController = storyboard.instantiateViewController(withIdentifier: "calendarChooser") as! CalendarViewController
                    self.present(newViewController, animated: false)
                } else {// user has never setup the app before, needs location details
                    newViewController = storyboard.instantiateViewController(withIdentifier: "search_a_place") as! GetUserLocationViewController
                    self.present(newViewController, animated: false)
                }
            }
        } else {// any other language
            newViewController = storyboard.instantiateViewController(withIdentifier: "zmanim languages") as! ZmanimLanguageViewController
            self.present(newViewController, animated: false)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            yes.setTitleColor(.white, for: .normal)
            yes.widthAnchor.constraint(equalToConstant: 100).isActive = true
            yes.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            no.setTitleColor(.black, for: .normal)
            no.widthAnchor.constraint(equalToConstant: 100).isActive = true
            no.heightAnchor.constraint(equalToConstant: 100).isActive = true
        }
    }
}
