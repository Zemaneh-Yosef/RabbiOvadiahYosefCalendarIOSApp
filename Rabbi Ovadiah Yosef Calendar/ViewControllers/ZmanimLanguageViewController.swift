//
//  ZmanimLanguageViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/18/23.
//

import UIKit

class ZmanimLanguageViewController: UIViewController {
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var isZmanimInHebrew: Bool = false
    var isZmanimEnglishTranslated: Bool = false

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var translated: UIButton!
    @IBOutlet weak var english: UIButton!
    @IBOutlet weak var hebrew: UIButton!
    @IBAction func hebrew(_ sender: UIButton) {
        isZmanimInHebrew = true
        isZmanimEnglishTranslated = false
        setImages()
    }
    @IBAction func English(_ sender: UIButton) {
        isZmanimInHebrew = false
        isZmanimEnglishTranslated = false
        setImages()
    }
    @IBAction func translatedEnglish(_ sender: UIButton) {
        isZmanimInHebrew = false
        if isZmanimEnglishTranslated {
            isZmanimEnglishTranslated = false
        } else {
            isZmanimEnglishTranslated = true
        }
        setImages()
    }
    @IBAction func confirm(_ sender: UIButton) {
        showNextView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        isZmanimInHebrew = defaults.bool(forKey: "isZmanimInHebrew")
        isZmanimEnglishTranslated = defaults.bool(forKey: "isZmanimEnglishTranslated")
        setImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setImages() {
        if isZmanimInHebrew {
            hebrew.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
            english.setImage(UIImage(systemName: "circle"), for: .normal)
            translated.setImage(UIImage(systemName: "square"), for: .normal)
            imageview.image = UIImage(named: "hebrew")
            translated.isEnabled = false
        } else if isZmanimEnglishTranslated {
            hebrew.setImage(UIImage(systemName: "circle"), for: .normal)
            english.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
            translated.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            imageview.image = UIImage(named: "translated")
            translated.isEnabled = true
        } else {
            hebrew.setImage(UIImage(systemName: "circle"), for: .normal)
            english.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
            translated.setImage(UIImage(systemName: "square"), for: .normal)
            imageview.image = UIImage(named: "english")
            translated.isEnabled = true
        }
    }
    
    func showNextView() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        defaults.set(isZmanimInHebrew, forKey: "isZmanimInHebrew")
        defaults.set(isZmanimEnglishTranslated, forKey: "isZmanimEnglishTranslated")
        defaults.set(true, forKey: "isSetup")
        
        if !defaults.bool(forKey: "hasShownTipScreen") {
            showFullScreenView("TipScreen")
            defaults.set(true, forKey: "hasShownTipScreen")
        } else {// dismiss everything
            let welcome = super.presentingViewController?.presentingViewController?.presentingViewController
            let getUserLocationView = super.presentingViewController?.presentingViewController
            let isIsrael = super.presentingViewController
            super.dismiss(animated: false) {//when this view is dismissed, dismiss the superview as well
                if isIsrael != nil {
                    isIsrael?.dismiss(animated: false)
                    if getUserLocationView != nil {
                        getUserLocationView?.dismiss(animated: false) {
                            if welcome != nil {
                                welcome?.dismiss(animated: false)
                            }
                        }
                    }
                }
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
