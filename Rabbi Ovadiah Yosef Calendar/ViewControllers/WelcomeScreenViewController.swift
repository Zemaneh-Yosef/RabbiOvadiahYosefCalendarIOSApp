//
//  WelcomeScreenViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/3/25.
//

import UIKit

class WelcomeScreenViewController: UIViewController {

    @IBAction func haskamot(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose a haskama to view".localized(), message: "Multiple rabbanim have given their haskama/approval to this app. Choose which one you would like to view.".localized(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Rabbi Elbaz (English)".localized(), style: .default) { (_) in
            if let url = URL(string: "https://royzmanim.com/assets/Haskamah.pdf") {
                    UIApplication.shared.open(url)
            }
        })
        alertController.addAction(UIAlertAction(title: "Rabbi Dahan (Hebrew)".localized(), style: .default) { (_) in
            if let url = URL(string: "https://royzmanim.com/assets/%D7%94%D7%A1%D7%9B%D7%9E%D7%94.pdf") {
                    UIApplication.shared.open(url)
            }
        })
        alertController.addAction(UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in })
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func aboutUs(_ sender: UIButton) {
        let alertController = UIAlertController(title: "About Us".localized(), message: "We are the platform to use whenever and wherever you'd need Halachic Times (Zemanim) according to Hakham Ovadia Yosef zt'l, following his practices represented in his Ohr Hachaim calendar from Eretz Yisrael. Outside Israel, our algorithm follow's the rules outlined by the Minḥat Kohen (as quoted by R David Yosef, approved by R Yitzḥak Yosef) to comply with the astronomical differences while sticking to seasonal minutes.".localized(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in })
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func getStarted(_ sender: UIButton) {
        showFullScreenView("search_a_place")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
