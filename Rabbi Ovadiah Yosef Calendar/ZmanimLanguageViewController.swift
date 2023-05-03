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
        dismissAllViews()
    }
    @IBAction func English(_ sender: UIButton) {
        defaults.set(false, forKey: "isZmanimInHebrew")
        defaults.set(false, forKey: "isZmanimEnglishTranslated")
        dismissAllViews()
    }
    @IBAction func translatedEnglish(_ sender: UIButton) {
        defaults.set(false, forKey: "isZmanimInHebrew")
        defaults.set(true, forKey: "isZmanimEnglishTranslated")
        dismissAllViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func dismissAllViews() {
        let inIsraelView = super.presentingViewController!
        super.dismiss(animated: true) {//when this view is dismissed, dismiss the superview as well
            inIsraelView.dismiss(animated: true)
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
