//
//  NetzViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 9/19/23.
//

import UIKit
import KosherSwift

class NetzViewController: UIViewController {

    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var countdownTimer: DispatchSourceTimer?

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

        var netz = ChaiTables(locationName: GlobalStruct.geoLocation.locationName, jewishCalendar: jewishCalendar, defaults: defaults).getVisibleSurise(forDate: zmanimCalendar.workingDate)

        if netz == nil {
            netz = zmanimCalendar.getSeaLevelSunrise()
        }

        if netz?.timeIntervalSinceNow ?? 0 < 0 {// if date is before now
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(86400)
            jewishCalendar.workingDate = zmanimCalendar.workingDate

            netz = ChaiTables(locationName: GlobalStruct.geoLocation.locationName, jewishCalendar: jewishCalendar, defaults: defaults).getVisibleSurise(forDate: zmanimCalendar.workingDate)
            if netz == nil {
                netz = zmanimCalendar.getSeaLevelSunrise()
            }
        }

        startCountdown(netz: netz ?? Date())
    }

    func startCountdown(netz: Date) {
        // Cancel any existing timer
        countdownTimer?.cancel()

        let netzNames = ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.unitsStyle = .short

        let targetTime = netz.timeIntervalSinceReferenceDate
        let queue = DispatchQueue.global(qos: .background)

        countdownTimer = DispatchSource.makeTimerSource(queue: queue)
        countdownTimer?.schedule(deadline: .now(), repeating: 1.0)

        countdownTimer?.setEventHandler { [weak self] in
            let now = Date().timeIntervalSinceReferenceDate
            let secondsRemaining = max(0, targetTime - now)

            DispatchQueue.main.async {
                if secondsRemaining > 0 {
                    let countdownText = netzNames.getHaNetzString()
                        .appending(netzNames.getIsInString())
                        .appending("\n\n")
                        .appending(formatter.string(from: secondsRemaining) ?? "")
                    self?.content.text = countdownText
                } else {
                    self?.countdownTimer?.cancel()
                    self?.countdownTimer = nil
                    self?.content.text = "Netz/Sunrise has passed. Count will automatically restart at sunset. Swipe down to countdown again.".localized()
                    self?.setTimerForSunset()
                }
            }
        }

        countdownTimer?.resume()
    }

    func setTimerForSunset() {
        let sunset = ComplexZmanimCalendar(location: GlobalStruct.geoLocation).getElevationAdjustedSunset()
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
}
