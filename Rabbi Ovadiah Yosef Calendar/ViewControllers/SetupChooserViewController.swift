//
//  SetupChooserViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Macbook Pro on 8/15/23.
//

import UIKit

class SetupChooserViewController: UIViewController {

    @IBOutlet weak var info: UIButton!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var simpleSetup: UIButton!
    @IBOutlet weak var advancedSetup: UIButton!
    
    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    
    @IBAction func info(_ sender: UIButton) {
        let message = "There are 2 options in order to download the visible sunrise times for your location.\n\n Pressing the \"Setup your city!\" button will take you to a page that will ask you to choose your city/area. Once you choose your city, it will download a table that lists the times for VISIBLE sunrise throughout the next 2 years from a website called ChaiTables.com.\n\nThe \"Advanced Setup\" option allows you to choose whether you want to supply your own URL for the chaitables website, or do navigate the website yourself.\n\nKnow that the visible sunrise data changes for each and every city and you will need to set the visible sunrise data of your city every time you change cities."
        
        let alertController = UIAlertController(title: "Introduction", message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in }
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func startSimpleSetup(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "SimpleSetup") as! SimpleSetupViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: false)
    }
    
    @IBAction func startAdvancedSetup(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "AdvancedSetup") as! AdvancedSetupViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            info.configuration = .filled()
            info.configuration?.background.backgroundColor = .systemBlue
            info.setTitleColor(.white, for: .normal)
            
            simpleSetup.configuration = .filled()
            simpleSetup.configuration?.background.backgroundColor = .init(named: "Gold")
            simpleSetup.setTitleColor(.black, for: .normal)
            
            advancedSetup.configuration = .filled()
            advancedSetup.configuration?.background.backgroundColor = .gray
            advancedSetup.setTitleColor(.white, for: .normal)
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
