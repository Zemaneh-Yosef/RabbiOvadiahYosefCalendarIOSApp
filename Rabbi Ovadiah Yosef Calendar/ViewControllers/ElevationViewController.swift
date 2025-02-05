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
            desc.text = "הרב אשר דרשן (שהיה בצוות לוח אור החיים בישראל) אמר לי שהרב עובדיה יוסף זצ\"ל סבר כי זמן הזריחה/שקיעה שיש להשתמש בו לחישוב הזמנים הוא כאשר הזריחה/שקיעה נראית בנקודה הגבוהה ביותר בעיר. עם זאת, הרב דוד יוסף שליט\"א כותב שרבים אמרו לו שהרב עובדיה זצ\"ל סבר שיש להשתמש בזריחה/שקיעה לפי מישור (גובה פני הים). הרב ליאור דהן אומר שהגיוני להשתמש בגובה בערים שיש בהן גבעות, ולא להשתמש בו כאשר העיר, למשל ניו יורק, קרובה לגובה פני הים. ניתן להשתמש בכפתורים למטה כדי לבחור את ההגדרות המתאימות עבורכם. (ראו הלכה ברורה חלק י\"ד, באוצרות יוסף (קונטרוס כי בא השמש), סימן ו', פרק כ\"א לדיון מעמיק)"
        } else {
            desc.text = "Rabbi Asher Darshan (who was on the team for the Ohr HaChaim calendar in Israel) told me that Rabbi Ovadiah Yosef ZT\"L held that the actual sunrise/sunset that should be used for calculating zmanim is when sunrise/sunset is seen at the highest point in the city. However, Rabbi David Yosef Shlita writes that many have told him that Rabbi Ovadiah ZT\"L held to use Mishor (Sea Level) sunrise/sunset. Rabbi Leeor Dahan says that it makes sense to use elevation in cities that have hills, and to not use it when the city, E.G. New York, is close to sea level. You can use the buttons below to choose the appropriate settings that you want. (See Halacha Berura vol. 14, in Otzrot Yosef (Kuntrus Ki Ba Hashemesh), Siman 6, Perek 21 for an in depth discussion)"
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
