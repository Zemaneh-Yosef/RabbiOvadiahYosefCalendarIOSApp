//
//  ElevationViewController.swift
//  Rabbeinu Tam
//
//  Created by Elyahu on 4/9/23.
//

import UIKit

class ElevationViewController: UIViewController {
    
    let _acceptableCharacters = "0123456789."
    
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
                let alert = UIAlertController(title: "Invalid input", message: "Please only enter numbers and decimals! For example: 30.0", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK!", style: .default) { (UIAlertAction) -> Void in
                }
                alert.addAction(alertAction)
                present(alert, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textfield.addTarget(self, action: #selector(onReturn), for: UIControl.Event.editingDidEndOnExit)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if #available(iOS 15.0, *) {
            getFromOnlineButton.configuration = .filled()
            getFromOnlineButton.configuration?.background.backgroundColor = .systemBlue
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
