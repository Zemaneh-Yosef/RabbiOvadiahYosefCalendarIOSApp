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
        presentNextView(inIsrael: true)
    }
    @IBAction func noButton(_ sender: UIButton) {
        presentNextView(inIsrael: false)
    }
    func presentNextView(inIsrael:Bool) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        defaults.set(inIsrael, forKey: "inIsrael")
        defaults.set(!inIsrael, forKey: "LuachAmudeiHoraah")
        defaults.set(inIsrael, forKey: "useElevation")
        
        if Locale.isHebrewLocale() {
            defaults.set(true, forKey: "isZmanimInHebrew")
            defaults.set(false, forKey: "isZmanimEnglishTranslated")
            defaults.set(true, forKey: "isSetup")
            if !defaults.bool(forKey: "hasShownTipScreen") {
                showFullScreenView("TipScreen")
                defaults.set(true, forKey: "hasShownTipScreen")
            } else {
                let welcome = super.presentingViewController?.presentingViewController?.presentingViewController
                let getUserLocationView = super.presentingViewController?.presentingViewController
                super.dismiss(animated: false) {//when this view is dismissed, dismiss the superview as well
                    if getUserLocationView != nil {
                        getUserLocationView?.dismiss(animated: false) {
                            if welcome != nil {
                                welcome?.dismiss(animated: false)
                            }
                        }
                    }
                }
            }
        } else {
            showFullScreenView("zmanim languages")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        yes.setTitleColor(.white, for: .normal)
        yes.widthAnchor.constraint(equalToConstant: 100).isActive = true
        yes.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        no.setTitleColor(.black, for: .normal)
        no.widthAnchor.constraint(equalToConstant: 100).isActive = true
        no.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}
