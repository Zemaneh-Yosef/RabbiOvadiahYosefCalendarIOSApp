//
//  ElevationViewController.swift
//  Rabbeinu Tam
//
//  Created by Elyahu on 4/9/23.
//

import UIKit

class ElevationViewController: UIViewController {
    
    let _acceptableCharacters = "0123456789."
    
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var getFromOnlineButton: UIButton!
    @IBAction func getFromOnline(_ sender: Any) {
        var intArray: [Int] = []
        var e1:Int = 0
        var e2:Int = 0
        var e3:Int = 0
        let group = DispatchGroup()
        group.enter()
        let geocoder = LSGeoLookup(withUserID: "Elyahu41")
        geocoder.findElevationGtopo30(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude) {
            elevation in
            if let elevation = elevation {
                e1 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.enter()
        geocoder.findElevationSRTM3(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude) {
            elevation in
            if let elevation = elevation {
                e2 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.enter()
        geocoder.findElevationAstergdem(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude) {
            elevation in
            if let elevation = elevation {
                e3 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.notify(queue: .main) {
            if e1 > 0 {
                intArray.append(e1)
            } else {
                e1 = 0
            }
            if e2 > 0 {
                intArray.append(e2)
            } else {
                e2 = 0
            }
            if e3 > 0 {
                intArray.append(e3)
            } else {
                e3 = 0
            }
            var count = Double(intArray.count)
            if count == 0 {
                count = 1 //edge case
            }
            let text = String(Double(e1 + e2 + e3) / Double(count))
            NotificationCenter.default.post(name: NSNotification.Name("elevation"), object: text)
            self.dismiss(animated: true)
        }
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBOutlet weak var textfield: UITextField!
    @IBAction func onReturn() {
        let text = textfield.text ?? ""
        if (!text.isEmpty) {
            if CharacterSet(charactersIn: _acceptableCharacters).isSuperset(of: CharacterSet(charactersIn: text)) {
                NotificationCenter.default.post(name: NSNotification.Name("elevation"), object: text)
                self.dismiss(animated: true)
            } else {
                let alert = UIAlertController(title: "Invalid input".localized(), message: "Please only enter numbers and decimals! For example: 30.0".localized(), preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK".localized().appending("!"), style: .default) { (UIAlertAction) -> Void in
                }
                alert.addAction(alertAction)
                present(alert, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textfield.addTarget(self, action: #selector(onReturn), for: UIControl.Event.editingDidEndOnExit)
        if Locale.isHebrewLocale() {
            desc.text = "קיימות דעות שמחזיקות כי השקיעה האמיתית שצריך להשתמש בה לחישוב זמני היום היא כאשר השקיעה נראית בנקודה הגבוהה ביותר בעיר. עם זאת, יש מי שאינם מחזיקים בדעה זו. לוח אור החיים משתמש בגובה לכל זמניו מאחר וישראל היא אזור הררי. באזורים בהם הם גרים קרוב לים, בדרך כלל לא משתמשים בגובה. עם זאת, רב דהאן עדכן אותי כי אפשר להשתמש בגובה גם באזורים שנמצאים בפני הים. לכן, כברירת מחדל, האפליקציה משתמשת בגובה, אך זה מופעל באופן ברירת מחדל עבור מצב עמודי הוראה. ניתן לציין ערך עבור הגובה הנוכחי שלך למטה:"
        } else {
            desc.text = "Some opinions hold that the actual sunset that should be used for calculating zmanim is when sunset is seen at the highest point in the city. However, some do not hold of this opinion. The Ohr HaChaim calendar uses elevation for all of it's zmanim since Israel is a mountainous region. In areas where they live close to the sea, elevation is usually not used. However, Rabbi Dahan has informed me that you can use elevation even at areas that are at sea level. Therefore, by default the app uses elevation, however, it is turned off for Amudei Horaah mode. You can specify a value for your current elevation below:"
        }
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if #available(iOS 15.0, *) {
            getFromOnlineButton.setTitleColor(.black, for: .normal)
        }
    }

//    @objc func keyboardWillShow(notification: NSNotification) {
//            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                        if self.view.frame.origin.y == 0 {
//                            self.view.frame.origin.y -= keyboardSize.height
//                        }
//                    }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//            if self.view.frame.origin.y != 0 {
//                        self.view.frame.origin.y = 0
//                    }
//    }
}
