//
//  NetzViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Macbook Pro on 9/19/23.
//

import UIKit
import KosherSwift

class NetzViewController: UIViewController {
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard

    @IBAction func quit(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    @IBOutlet weak var content: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a swipe gesture recognizer
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))

        swipeGesture.direction = .down
        swipeGesture.numberOfTouchesRequired = 1

        self.view.addGestureRecognizer(swipeGesture)
        
        getNextNetzAndStartCountdown()
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            getNextNetzAndStartCountdown()
        }
    }
    
    func getNextNetzAndStartCountdown() {
        let zmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
        zmanimCalendar.geoLocation.elevation = 0 // just in case
        let jewishCalendar = JewishCalendar()
        
        var netz = ChaiTables(locationName: GlobalStruct.geoLocation.locationName, jewishYear: jewishCalendar.getJewishYear(), defaults: defaults).getVisibleSurise(forDate: zmanimCalendar.workingDate)
        
        if netz == nil {
            netz = zmanimCalendar.getSeaLevelSunrise()
        }
        
        if netz?.timeIntervalSinceNow ?? 0 < 0 {// if date is before now
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(86400)
            jewishCalendar.workingDate = zmanimCalendar.workingDate
            
            netz = ChaiTables(locationName: GlobalStruct.geoLocation.locationName, jewishYear: jewishCalendar.getJewishYear(), defaults: defaults).getVisibleSurise(forDate: zmanimCalendar.workingDate)
            if netz == nil {
                netz = zmanimCalendar.getSeaLevelSunrise()
            }
        }
        
        startCountdown(netz: netz ?? Date())
    }
    
    func startCountdown(netz:Date) {
        var secondsRemaining = netz.timeIntervalSinceNow
        let netzNames = ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.unitsStyle = .short
                                        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if secondsRemaining > 0 {
                let s = netzNames.getHaNetzString().appending(netzNames.getIsInString()).appending("\n\n").appending(formatter.string(from: secondsRemaining)!)
                self.content.text = s
                secondsRemaining -= 1
            } else {
                Timer.invalidate()
                self.content.text = "Netz/Sunrise has passed. Count will automatically restart at sunset. Swipe down to countdown again."
                self.setTimerForSunset()
            }
        }
    }
    
    func setTimerForSunset() {
        let sunset = ComplexZmanimCalendar(location: GlobalStruct.geoLocation).getSunset()
        var sunsetTimeLeft = sunset?.timeIntervalSinceNow
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if sunsetTimeLeft ?? 0 > 0 {
                sunsetTimeLeft! -= 1
            } else {
                Timer.invalidate()
                self.getNextNetzAndStartCountdown()
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
