//
//  CalendarViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 6/12/23.
//

import UIKit

class TipScreenViewController: UIViewController {
    
    @IBAction func info(_ sender: UIButton) {
     
    }

    @IBOutlet weak var amudeiHoraah: UIButton!
    @IBAction func skip(_ sender: UIButton) {
        dismissAllViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    func dismissAllViews() {
        let inIsraelView = super.presentingViewController?.presentingViewController?.presentingViewController
        let zmanimLanguagesView = super.presentingViewController?.presentingViewController
        let getUserLocationView = super.presentingViewController
        
        super.dismiss(animated: false) {//when this view is dismissed, dismiss the superview as well
            if getUserLocationView != nil {
                getUserLocationView?.dismiss(animated: false)
                if zmanimLanguagesView != nil {
                    zmanimLanguagesView?.dismiss(animated: false) {
                        if inIsraelView != nil {
                            inIsraelView?.dismiss(animated: false)
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
