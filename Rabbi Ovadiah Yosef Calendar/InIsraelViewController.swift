//
//  InIsraelViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/18/23.
//

import UIKit

class InIsraelViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var no: UIButton!
    @IBOutlet weak var yes: UIButton!
    @IBAction func yesButton(_ sender: UIButton) {
        defaults.setValue(true, forKey: "inIsrael")
        presentZmanimLanguages()
    }
    @IBAction func noButton(_ sender: UIButton) {
        defaults.setValue(false, forKey: "inIsrael")
        presentZmanimLanguages()
    }
    func presentZmanimLanguages() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "zmanim languages") as! ZmanimLanguageViewController
        self.present(newViewController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            yes.configuration = .filled()
            yes.configuration?.background.backgroundColor = .systemBlue
            yes.widthAnchor.constraint(equalToConstant: 100).isActive = true
            yes.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            no.configuration = .filled()
            no.configuration?.background.backgroundColor = .init(named: "Gold")
            no.setTitleColor(.black, for: .normal)
            no.widthAnchor.constraint(equalToConstant: 100).isActive = true
            no.heightAnchor.constraint(equalToConstant: 100).isActive = true
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
