//
//  CalendarViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 6/12/23.
//

import UIKit

class CalendarViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBAction func info(_ sender: UIButton) {
        let longInfoMessage = "This app has the capability to display two separate calendars. In 1990, Rabbi Ovadiah Yosef ZT\"L started a project to create a zmanim calendar according to his halachot and minhagim. Therefore, Rabbi Ovadiah sat down with Rabbi Shlomo Benizri and Rabbi Asher Darshan and created a zmanim calendar called \"Luach HaMaor Ohr HaChaim\". Rabbi Ovadiah himself oversaw this calendar's creation and used it until he passed. The code for that calendar is not available to the public, however, they explain how to do the calculations in their introduction and this app has reverse engineered all the zmanim of the Ohr Hachaim calendar and confirmed that they are accurate. \n\n There is also an option to use the Amudei Horaah calendar created by Rabbi Leeor Dahan Shlita. Rabbi Leeor Dahan is the author of the popular sefer \"Amudei Horaah\", and as he lives in America, he has set out to create his own calendar according to Rabbi Ovadiah's views. His calendar is similar to the Ohr HaChaim calendar with minor differences, however, based on the Halacha Berurah, he adjusts Alot and Tzeit based on the degrees of the location of the user. In depth explanation is available in the app. The only zmanim that are shown on the Amudei Horaah calendar that are not shown in the Ohr HaChaim calendar plag hamincha according to the Halacha Berurah and tzeit l'chumra. I assume the Halacha Berurah was not shown in the Ohr HaChaim calendar because the Halacha Berurah was fairly new at the time. Tzeit l'chumra is 20 zmaniyot minutes translated as degrees and is used in certain scenarios like for when a fast ends. Rabbi Benizri has told me that it is 20 regular minutes after sunset. I asked Rabbi Benizri why there was no mention of this stringent tzeit in the Ohr Hachaim calendar and he answered that the calendar just says that the fasts end at tzeit and it refers to both times. \n\n It should be noted that both calendars will use the latitude and longitude you provide to calculate the zmanim. There is just a difference of a few minutes between the two calendars because of the additional degrees added. Also, Rabbi Dahan agrees that you should be using the Ohr HaChaim calendar IN ISRAEL. The Amudei Horaah calendar is only to be used outside of israel. Rabbi Shlomo Benizri Shlita however holds that the Ohr HaChaim calendar CAN be used outside Israel as well as Rabbi Ovadiah never differentiated."
        
        var alertController = UIAlertController(title: "Calendar Choice Page Explained", message: longInfoMessage, preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Calendar Choice Page Explained", message: longInfoMessage, preferredStyle: .alert)
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in }
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
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
