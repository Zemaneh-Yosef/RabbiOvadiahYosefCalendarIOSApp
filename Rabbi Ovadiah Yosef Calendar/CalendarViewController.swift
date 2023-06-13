//
//  CalendarViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 6/12/23.
//

import UIKit

class CalendarViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBAction func amudeiHoraah(_ sender: UIButton) {
        defaults.setValue(true, forKey: "LuachAmudeiHoraah")
        dismissAllViews()
    }
    
    @IBOutlet weak var ohrHachaim: UIButton!
    @IBAction func ohrHachaim(_ sender: UIButton) {
        defaults.setValue(false, forKey: "LuachAmudeiHoraah")
        dismissAllViews()
    }
    @IBOutlet weak var amudeiHoraah: UIButton!
    @IBAction func skip(_ sender: UIButton) {
        dismissAllViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            ohrHachaim.configuration = .filled()
            ohrHachaim.configuration?.background.backgroundColor = .init(named: "Gold")
            ohrHachaim.setTitleColor(.black, for: .normal)
            
            amudeiHoraah.configuration = .filled()
            amudeiHoraah.configuration?.background.backgroundColor = .init(named: "Gold")
            amudeiHoraah.setTitleColor(.black, for: .normal)
        }
    }
    
    func dismissAllViews() {
        let inIsraelView = super.presentingViewController?.presentingViewController!
        let zmanimLanguagesView = super.presentingViewController!
        
        super.dismiss(animated: true) {//when this view is dismissed, dismiss the superview as well
            zmanimLanguagesView.dismiss(animated: true) {
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
