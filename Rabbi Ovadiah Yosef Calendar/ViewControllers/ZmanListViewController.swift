//
//  ViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 2/10/23.
//

import UIKit
import KosherSwift
import CoreLocation
import ActivityKit
import WatchConnectivity

class ZmanListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WCSessionDelegate {
    
    var locationName: String = ""
    var lat: Double = 0
    var long: Double = 0
    var elevation: Double = 0.0
    var timezone: TimeZone = TimeZone.current
    var shabbatMode: Bool = false
    var userChosenDate: Date = Date()
    var lastTimeUserWasInApp: Date = Date()
    var nextUpcomingZman: Date? = nil
    var zmanimCalendar: ComplexZmanimCalendar = ComplexZmanimCalendar()
    var jewishCalendar: JewishCalendar = JewishCalendar()
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var zmanimList = Array<ZmanListEntry>()
    let dateFormatterForZmanim = DateFormatter()
    var timerForShabbatMode: Timer?
    var timerForNextZman: Timer?
    var currentIndex = 0
    var shouldScroll = true
    var askedToUpdateTablesAlready = false
    var wcSession : WCSession! = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBAction func prevDayButton(_ sender: Any) {
        userChosenDate = userChosenDate.advanced(by: -86400)
        syncCalendarDates()
        updateZmanimList()
        checkIfTablesNeedToBeUpdated()
        zmanimTableView.scrollToRow(at: .init(row: 0, section: 0), at: .bottom, animated: false)
    }
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var prevDayButton: UIButton!
    @IBOutlet weak var nextDayButton: UIButton!
    @IBAction func calendarButton(_ sender: Any) {
        showDatePicker()
    }
    @IBAction func nextDayButton(_ sender: Any) {
        userChosenDate = userChosenDate.advanced(by: 86400)
        syncCalendarDates()
        updateZmanimList()
        checkIfTablesNeedToBeUpdated()
        zmanimTableView.scrollToRow(at: .init(row: 0, section: 0), at: .bottom, animated: false)
    }
    @IBOutlet weak var ShabbatModeBanner: MarqueeLabel!
    @IBOutlet weak var menuButton: UIButton!
    
    func createMenu() {
        var topMenu:[UIAction] = []
        var bottomMenu:[UIAction] = []
        
        topMenu.append(UIAction(title: "Shabbat/Chag Mode".localized(), identifier: nil, state: self.shabbatMode ? .on : .off) { _ in
            if self.shabbatMode {
                self.endShabbatMode()
            } else {
                self.startShabbatMode()
            }
            self.createMenu()
        })
                
        topMenu.append(UIAction(title: "Use Elevation".localized(), identifier: nil, state: self.defaults.bool(forKey: "useElevation") ? .on : .off) { _ in
            self.defaults.set(!self.defaults.bool(forKey: "useElevation"), forKey: "useElevation")
            GlobalStruct.useElevation = self.defaults.bool(forKey: "useElevation")
            self.resolveElevation()
            self.createMenu()
            self.recreateZmanimCalendar()
            self.setNextUpcomingZman()
            self.updateZmanimList()
        })
        
        topMenu.append(UIAction(title: "Netz Countdown".localized(), identifier: nil) { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "Netz") as! NetzViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true)
        })
        
        topMenu.append(UIAction(title: "Molad Calculator".localized(), identifier: nil) { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "Molad") as! MoladViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true)
        })
        
        bottomMenu.append(UIAction(title: "Setup".localized(), identifier: nil) { _ in
            self.showSetup()
        })
        
        bottomMenu.append(UIAction(title: "Search For A Place".localized(), identifier: nil) { _ in
            self.showZipcodeAlert()
        })
        
        bottomMenu.append(UIAction(title: "Website".localized(), identifier: nil) { _ in
            if let url = URL(string: "https://royzmanim.com/") {
                    UIApplication.shared.open(url)
            }
        })
        
        bottomMenu.append(UIAction(title: "Settings".localized(), identifier: nil) { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true)
        })
        
        var menu: UIMenu
        menu = UIMenu(options: .displayInline, children: [UIMenu(title: "", options: .displayInline, children: topMenu), UIMenu(options: .displayInline, children:[UIMenu(title: "", options: .displayInline, children: bottomMenu)])])
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {// an actual iPad is okay with the above format, but for some reason, mac emulation does not handle the menu as well. 
            topMenu.append(UIAction(title: "Setup".localized(), identifier: nil) { _ in
                self.showSetup()
            })
            
            topMenu.append(UIAction(title: "Search For A Place".localized(), identifier: nil) { _ in
                self.showZipcodeAlert()
            })
            
            topMenu.append(UIAction(title: "Website".localized(), identifier: nil) { _ in
                if let url = URL(string: "https://royzmanim.com/") {
                        UIApplication.shared.open(url)
                }
            })
            
            topMenu.append(UIAction(title: "Settings".localized(), identifier: nil) { _ in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true)
            })
            menu = UIMenu(options: .displayInline, children: topMenu)
        }
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true
    }
    @IBAction func setupElevetion(_ sender: Any) {
        self.performSegue(withIdentifier: "elevationSegue", sender: self)
    }
    @IBOutlet weak var zmanimTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zmanimList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ZmanEntry", for: indexPath)
        var zman = zmanimList[indexPath.row].zman
        dateFormatterForZmanim.timeZone = timezone
        
        var content = cell.defaultContentConfiguration()
        content.textProperties.adjustsFontSizeToFitWidth = true
        content.textProperties.numberOfLines = 1
        
        if zmanimList[indexPath.row].isZman {
            if defaults.bool(forKey: "isZmanimInHebrew") {
                if zman == nil {
                    content.secondaryText = zmanimList[indexPath.row].title
                    content.text = "XX:XX"
                } else {
                    content.secondaryText = zmanimList[indexPath.row].title
                    if zman == nextUpcomingZman {
                        let arrow = "◄"
                        if zmanimList[indexPath.row].isRTZman && defaults.bool(forKey: "roundUpRT") {
                            zman = zman?.advanced(by: 60)
                            let roundedFormat = DateFormatter()
                            roundedFormat.timeZone = timezone
                            if Locale.isHebrewLocale() {
                                roundedFormat.dateFormat = "H:mm"
                            } else {
                                roundedFormat.dateFormat = "h:mm aa"
                            }
                            content.text = roundedFormat.string(from: zman!) + arrow
                        } else if zmanimList[indexPath.row].isVisibleSunriseZman {
                            let secondsFormat = DateFormatter()
                            if Locale.isHebrewLocale() {
                                secondsFormat.dateFormat = "H:mm:ss"
                            } else {
                                secondsFormat.dateFormat = "h:mm:ss aa"
                            }
                            content.text = secondsFormat.string(from: zman!) + arrow
                        } else {
                            content.text = dateFormatterForZmanim.string(from: zman!) + arrow
                        }
                    } else {
                        if zmanimList[indexPath.row].isRTZman && defaults.bool(forKey: "roundUpRT") {
                            zman = zman?.advanced(by: 60)
                            let roundedFormat = DateFormatter()
                            roundedFormat.timeZone = timezone
                            if Locale.isHebrewLocale() {
                                roundedFormat.dateFormat = "H:mm"
                            } else {
                                roundedFormat.dateFormat = "h:mm aa"
                            }
                            content.text = roundedFormat.string(from: zman!)
                        } else if zmanimList[indexPath.row].isVisibleSunriseZman {
                            let secondsFormat = DateFormatter()
                            if Locale.isHebrewLocale() {
                                secondsFormat.dateFormat = "H:mm:ss"
                            } else {
                                secondsFormat.dateFormat = "h:mm:ss aa"
                            }
                            content.text = secondsFormat.string(from: zman!)
                        }  else {
                            content.text = dateFormatterForZmanim.string(from: zman!)
                        }
                    }
                }
                content.textProperties.font = .boldSystemFont(ofSize: 20)
                content.secondaryTextProperties.font = .boldSystemFont(ofSize: 20)
                content.prefersSideBySideTextAndSecondaryText = true
            } else {//english
                if zman == nil {
                    content.text = zmanimList[indexPath.row].title
                    content.secondaryText = "XX:XX"
                } else {
                    content.text = zmanimList[indexPath.row].title
                    if zman == nextUpcomingZman {
                        let arrow = "➤"
                        if zmanimList[indexPath.row].isRTZman && defaults.bool(forKey: "roundUpRT") {
                            zman = zman?.advanced(by: 60)
                            let roundedFormat = DateFormatter()
                            roundedFormat.timeZone = timezone
                            roundedFormat.dateFormat = "h:mm aa"
                            content.secondaryText = arrow + roundedFormat.string(from: zman!)
                        } else if zmanimList[indexPath.row].isVisibleSunriseZman {
                            let secondsFormat = DateFormatter()
                            secondsFormat.dateFormat = "h:mm:ss aa"
                            content.secondaryText = secondsFormat.string(from: zman!) + arrow
                        } else {
                            content.secondaryText = arrow + dateFormatterForZmanim.string(from: zman!)
                        }
                    } else {
                        if zmanimList[indexPath.row].isRTZman && defaults.bool(forKey: "roundUpRT") {
                            zman = zman?.advanced(by: 60)
                            let roundedFormat = DateFormatter()
                            roundedFormat.timeZone = timezone
                            roundedFormat.dateFormat = "h:mm aa"
                            content.secondaryText = roundedFormat.string(from: zman!)
                        } else if zmanimList[indexPath.row].isVisibleSunriseZman {
                            let secondsFormat = DateFormatter()
                            secondsFormat.dateFormat = "h:mm:ss aa"
                            content.secondaryText = secondsFormat.string(from: zman!)
                        } else {
                            content.secondaryText = dateFormatterForZmanim.string(from: zman!)
                        }
                    }
                }
                content.textProperties.font = .boldSystemFont(ofSize: 20)
                content.secondaryTextProperties.font = .boldSystemFont(ofSize: 20)
                content.prefersSideBySideTextAndSecondaryText = true
            }
        } else {
            content.textProperties.alignment = .center
            content.text = zmanimList[indexPath.row].title
        }
        
        if zmanimList[indexPath.row].shouldBeDimmed {
            content.textProperties.color = .lightGray
            content.secondaryTextProperties.color = .lightGray
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if shabbatMode || !defaults.bool(forKey: "showZmanDialogs") {
            endShabbatMode()
            return//do not show the dialogs
        }
        
        let zmanimInfo = ZmanimAlertInfoHolder.init(title: zmanimList[indexPath.row].title, mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        
        let candleLightingOffset = zmanimCalendar.candleLightingOffset
        let shabbatOffset = zmanimCalendar.ateretTorahSunsetOffset
        
        var alertController = UIAlertController(title: zmanimInfo.getFullTitle(), message: zmanimInfo.getFullMessage().replacingOccurrences(of: "%c", with: String(candleLightingOffset)).replacingOccurrences(of: "%s", with: String(shabbatOffset)), preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: zmanimInfo.getFullTitle(), message: zmanimInfo.getFullMessage().replacingOccurrences(of: "%c", with: String(candleLightingOffset)).replacingOccurrences(of: "%s", with: String(shabbatOffset)), preferredStyle: .alert)
        }
        
        if indexPath.row == 0 {
            var message = ""
            message += "Current Location: " + self.locationName
            message += "\nCurrent Latitude: " + String(self.lat)
            message += "\nCurrent Longitude: " + String(self.long)
            message += "\nElevation: " + String(self.elevation) + " meters"
            message += "\nCurrent Time Zone: " + self.timezone.identifier
            if let marketingVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                message += "\nVersion: \(marketingVersion)"
            } else {
                print("Marketing version number not found.")
            }
            
            alertController.title = "Location info for: " + self.locationName
            alertController.message = message
            let locationAction = UIAlertAction(title: "Change Location".localized(), style: .default) { [self] (_) in
                self.showZipcodeAlert()
            }
            alertController.addAction(locationAction)
            if !defaults.bool(forKey: "LuachAmudeiHoraah") {
                let elevationAction = UIAlertAction(title: "Set Elevation".localized(), style: .default) { [self] (_) in
                    self.setupElevetion((Any).self)
                }
                alertController.addAction(elevationAction)
            }
        }
        
        if zmanimList[indexPath.row].title.contains(ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getHaNetzString()) {
            let setupSunriseAction = UIAlertAction(title: "Setup Visible Sunrise".localized(), style: .default) { [self] (_) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyboard.instantiateViewController(withIdentifier: "SetupChooser") as! SetupChooserViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true)
            }
            alertController.addAction(setupSunriseAction)
        }
        
        if zmanimList[indexPath.row].title == "Daily Siddur".localized() || zmanimList[indexPath.row].title == "Daily Siddur".localized().appending("*") {
            GlobalStruct.jewishCalendar = jewishCalendar
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "SiddurChooser") as! SiddurChooserViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true)
        }
        
        if #available(iOS 16.2, *) {
            if zmanimList[indexPath.row].isZman
                && (zmanimList[indexPath.row].zman?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 > Date().timeIntervalSince1970) //after now
                && zmanimList[indexPath.row].zman?.timeIntervalSinceNow ?? Date().timeIntervalSinceNow < 28800 {// not after 8 hours
                let activityAction = UIAlertAction(title: "Keep track of this zman with a Live Activity?".localized(), style: .default) {_ in 
                    let attributes = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes(zmanName: self.zmanimList[indexPath.row].title)
                    let contentState = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes.TimerStatus(endTime: self.zmanimList[indexPath.row].zman ?? Date())
                    _ = try? Activity<Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes>.request(attributes: attributes, content: ActivityContent.init(state: contentState, staleDate: nil), pushType: nil)
                }
                alertController.addAction(activityAction)
            }
        }

        let dismissAction = UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in }
        alertController.addAction(dismissAction)

        if !zmanimInfo.getFullMessage().isEmpty || indexPath.row == 0 {
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func refreshTable() {
        if defaults.bool(forKey: "useAdvanced") {
            setLocation(defaultsLN: "advancedLN", defaultsLat: "advancedLat", defaultsLong: "advancedLong", defaultsTimezone: "advancedTimezone")
        } else if defaults.bool(forKey: "useLocation1") {
            setLocation(defaultsLN: "location1", defaultsLat: "location1Lat", defaultsLong: "location1Long", defaultsTimezone: "location1Timezone")
        } else if defaults.bool(forKey: "useLocation2") {
            setLocation(defaultsLN: "location2", defaultsLat: "location2Lat", defaultsLong: "location2Long", defaultsTimezone: "location2Timezone")
        } else if defaults.bool(forKey: "useLocation3") {
            setLocation(defaultsLN: "location3", defaultsLat: "location3Lat", defaultsLong: "location3Long", defaultsTimezone: "location3Timezone")
        } else if defaults.bool(forKey: "useLocation4") {
            setLocation(defaultsLN: "location4", defaultsLat: "location4Lat", defaultsLong: "location4Long", defaultsTimezone: "location4Timezone")
        } else if defaults.bool(forKey: "useLocation5") {
            setLocation(defaultsLN: "location5", defaultsLat: "location5Lat", defaultsLong: "location5Long", defaultsTimezone: "location5Timezone")
        } else if defaults.bool(forKey: "useZipcode") {
            setLocation(defaultsLN: "locationName", defaultsLat: "lat", defaultsLong: "long", defaultsTimezone: "timezone")
        } else {
            getUserLocation()
        }
        userChosenDate = Date()
        syncCalendarDates()
        updateZmanimList()
        zmanimTableView.refreshControl?.endRefreshing()
    }
    
    @objc func showDatePicker() {
        var alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .alert)
        }

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = userChosenDate
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(datePicker)

        // Add constraints to the date picker that pin it to the edges of the alert controller's view
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 32).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -32).isActive = true
        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 64).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -96).isActive = true
        
        let changeCalendarAction = UIAlertAction(title: "Switch Calendar".localized(), style: .default) { (_) in
            self.dismiss(animated: true)
            self.showHebrewDatePicker()
        }

        alertController.addAction(changeCalendarAction)

        let doneAction = UIAlertAction(title: "OK".localized(), style: .default) { (_) in
            self.syncCalendarDates()
            self.updateZmanimList()
            self.checkIfTablesNeedToBeUpdated()
            self.zmanimTableView.scrollToRow(at: .init(row: 0, section: 0), at: .bottom, animated: false)
        }

        alertController.addAction(doneAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showHebrewDatePicker() {
        var alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .alert)
        }

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.calendar = Calendar(identifier: .hebrew)
        datePicker.locale = Locale(identifier: "he")
        datePicker.date = userChosenDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(datePicker)

        // Add constraints to the date picker that pin it to the edges of the alert controller's view
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 32).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -32).isActive = true
        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 64).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -96).isActive = true
        
        let changeCalendarAction = UIAlertAction(title: "Switch Calendar".localized(), style: .default) { (_) in
            self.dismiss(animated: true)
            self.showDatePicker()
        }

        alertController.addAction(changeCalendarAction)

        let doneAction = UIAlertAction(title: "OK".localized(), style: .default) { (_) in
            self.syncCalendarDates()
            self.updateZmanimList()
            self.checkIfTablesNeedToBeUpdated()
            self.zmanimTableView.scrollToRow(at: .init(row: 0, section: 0), at: .bottom, animated: false)
        }

        alertController.addAction(doneAction)

        present(alertController, animated: true, completion: nil)
    }

    // Function to handle changes to the date picker value
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        userChosenDate = sender.date
    }
    
    func getSettingsDictionary() -> [String : Any] {
        return ["useElevation" : defaults.bool(forKey: "useElevation"),
                "showSeconds" : defaults.bool(forKey: "showSeconds"),
                "inIsrael" : defaults.bool(forKey: "inIsrael"),
                "tekufaOpinion" : defaults.integer(forKey: "tekufaOpinion"),
                "LuachAmudeiHoraah" : defaults.bool(forKey: "LuachAmudeiHoraah"),
                "isZmanimInHebrew" : defaults.bool(forKey: "isZmanimInHebrew"),
                "isZmanimEnglishTranslated" : defaults.bool(forKey: "isZmanimEnglishTranslated"),
                "visibleSunriseTable\(locationName)\(jewishCalendar.getJewishYear())" : defaults.string(forKey: "visibleSunriseTable\(locationName)\(jewishCalendar.getJewishYear())") ?? "",
                "alwaysShowMishorSunrise" : defaults.bool(forKey: "alwaysShowMishorSunrise"),
                "plagOpinion" : defaults.integer(forKey: "plagOpinion"),
                "candleLightingOffset" : defaults.integer(forKey: "candleLightingOffset"),
                "showWhenShabbatChagEnds" : defaults.bool(forKey: "showWhenShabbatChagEnds"),
                "showRegularWhenShabbatChagEnds" : defaults.bool(forKey: "showRegularWhenShabbatChagEnds"),
                "shabbatOffset" : defaults.integer(forKey: "shabbatOffset"),
                "endOfShabbatOpinion" : defaults.integer(forKey: "endOfShabbatOpinion"),
                "showRTWhenShabbatChagEnds" : defaults.bool(forKey: "showRTWhenShabbatChagEnds"),
                "showTzeitLChumra" : defaults.bool(forKey: "showTzeitLChumra"),
                "alwaysShowRT" : defaults.bool(forKey: "alwaysShowRT"),
                "useZipcode" : defaults.string(forKey: "useZipcode") ?? "",
                "locationName" : defaults.string(forKey: "locationName") ?? "",
                "lat" : defaults.double(forKey: "lat"),
                "long" : defaults.double(forKey: "long"),
                "elevation" + locationName : defaults.double(forKey: "elevation" + locationName),
                "setElevationToLastKnownLocation" : defaults.bool(forKey: "setElevationToLastKnownLocation"),
                "lastKnownLocation" : defaults.string(forKey: "lastKnownLocation") ?? "",
                "timezone" : defaults.string(forKey: "timezone") ?? "",
                "useAdvanced" : defaults.bool(forKey: "useAdvanced"),
                "advancedLN" : defaults.string(forKey: "advancedLN") ?? "",
                "advancedLat" : defaults.double(forKey: "advancedLat"),
                "advancedLong" : defaults.double(forKey: "advancedLong"),
                "advancedTimezone" : defaults.string(forKey: "advancedTimezone") ?? "",
                "useLocation1" : defaults.bool(forKey: "useLocation1"),
                "useLocation2" : defaults.bool(forKey: "useLocation2"),
                "useLocation3" : defaults.bool(forKey: "useLocation3"),
                "useLocation4" : defaults.bool(forKey: "useLocation4"),
                "useLocation5" : defaults.bool(forKey: "useLocation5"),
                "location1" : defaults.string(forKey: "location1") ?? "",
                "location1Lat" : defaults.double(forKey: "location1Lat"),
                "location1Long" : defaults.double(forKey: "location1Long"),
                "location1Timezone" : defaults.string(forKey: "location1Timezone") ?? "",
                "location2" : defaults.string(forKey: "location2") ?? "",
                "location2Lat" : defaults.double(forKey: "location2Lat"),
                "location2Long" : defaults.double(forKey: "location2Long"),
                "location2Timezone" : defaults.string(forKey: "location2Timezone") ?? "",
                "location3" : defaults.string(forKey: "location3") ?? "",
                "location3Lat" : defaults.double(forKey: "location3Lat"),
                "location3Long" : defaults.double(forKey: "location3Long"),
                "location3Timezone" : defaults.string(forKey: "location3Timezone") ?? "",
                "location4" : defaults.string(forKey: "location4") ?? "",
                "location4Lat" : defaults.double(forKey: "location4Lat"),
                "location4Long" : defaults.double(forKey: "location4Long"),
                "location4Timezone" : defaults.string(forKey: "location4Timezone") ?? "",
                "location5" : defaults.string(forKey: "location5") ?? "",
                "location5Lat" : defaults.double(forKey: "location5Lat"),
                "location5Long" : defaults.double(forKey: "location5Long"),
                "location5Timezone" : defaults.string(forKey: "location5Timezone") ?? "",
               ]
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if wcSession != nil {
            if wcSession.isPaired {
                if wcSession.isWatchAppInstalled {
                    wcSession.sendMessage(getSettingsDictionary(), replyHandler: nil)
                }
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    override func viewDidLoad() {//first this happens
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        zmanimTableView.dataSource = self
        zmanimTableView.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        zmanimTableView.refreshControl = refreshControl
        if !defaults.bool(forKey: "isSetup") {
            defaults.set(true, forKey: "useElevation")
            defaults.set(true, forKey: "showZmanDialogs")
            setBooleansForNotifications()
        }
        GlobalStruct.useElevation = defaults.bool(forKey: "useElevation")
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotification(_:)), name: NSNotification.Name("elevation"), object: nil)
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGestureRecognizer.direction = .right
        swipeLeftGestureRecognizer.direction = .left
        zmanimTableView.addGestureRecognizer(swipeGestureRecognizer)
        zmanimTableView.addGestureRecognizer(swipeLeftGestureRecognizer)
        createMenu()
        let hideBannerGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        ShabbatModeBanner.isUserInteractionEnabled = true
        ShabbatModeBanner.addGestureRecognizer(hideBannerGestureRecognizer)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            titleLabel.textAlignment = .natural
        }
        if Locale.isHebrewLocale() {
            titleLabel.text = "              זמני יוסף      "
        }
        toolbar.semanticContentAttribute = .forceLeftToRight
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {//this method happens 2nd
        super.viewWillAppear(animated)
        if Locale.isHebrewLocale() {
            if defaults.bool(forKey: "showSeconds") {
                dateFormatterForZmanim.dateFormat = "H:mm:ss"
            } else {
                dateFormatterForZmanim.dateFormat = "H:mm"
            }
        } else {
            if defaults.bool(forKey: "showSeconds") {
                dateFormatterForZmanim.dateFormat = "h:mm:ss aa"
            } else {
                dateFormatterForZmanim.dateFormat = "h:mm aa"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {//this method happens last
        super.viewDidAppear(animated)
        syncOldDefaults()
        if !defaults.bool(forKey: "isSetup") {
            if !defaults.bool(forKey: "setupShown") {
                showSetup()
            }
            showZipcodeAlert()
        } else { //not first run
            if defaults.bool(forKey: "useAdvanced") {
                setLocation(defaultsLN: "advancedLN", defaultsLat: "advancedLat", defaultsLong: "advancedLong", defaultsTimezone: "advancedTimezone")
            } else if defaults.bool(forKey: "useLocation1") {
                setLocation(defaultsLN: "location1", defaultsLat: "location1Lat", defaultsLong: "location1Long", defaultsTimezone: "location1Timezone")
            } else if defaults.bool(forKey: "useLocation2") {
                setLocation(defaultsLN: "location2", defaultsLat: "location2Lat", defaultsLong: "location2Long", defaultsTimezone: "location2Timezone")
            } else if defaults.bool(forKey: "useLocation3") {
                setLocation(defaultsLN: "location3", defaultsLat: "location3Lat", defaultsLong: "location3Long", defaultsTimezone: "location3Timezone")
            } else if defaults.bool(forKey: "useLocation4") {
                setLocation(defaultsLN: "location4", defaultsLat: "location4Lat", defaultsLong: "location4Long", defaultsTimezone: "location4Timezone")
            } else if defaults.bool(forKey: "useLocation5") {
                setLocation(defaultsLN: "location5", defaultsLat: "location5Lat", defaultsLong: "location5Long", defaultsTimezone: "location5Timezone")
            } else if defaults.bool(forKey: "useZipcode") {
                setLocation(defaultsLN: "locationName", defaultsLat: "lat", defaultsLong: "long", defaultsTimezone: "timezone")
            } else {
                getUserLocation()
            }
        }
        defaults.set(locationName, forKey: "lastKnownLocation")
        checkIfUserIsInIsrael()
        checkIfTablesNeedToBeUpdated()
        createBackgroundThreadForNextUpcomingZman()
        if !Calendar.current.isDate(lastTimeUserWasInApp, inSameDayAs: Date()) && lastTimeUserWasInApp.timeIntervalSinceNow < 7200 {//2 hours
            refreshTable()
        } else {
            updateZmanimList()
        }
        NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
        lastTimeUserWasInApp = Date()
        if WCSession.isSupported() && !(wcSession.activationState == .activated) {
            wcSession.activate()
        }
    }
    
    func setLocation(defaultsLN:String, defaultsLat:String, defaultsLong:String, defaultsTimezone:String) {
        locationName = defaults.string(forKey: defaultsLN) ?? ""
        lat = defaults.double(forKey: defaultsLat)
        long = defaults.double(forKey: defaultsLong)
        resolveElevation()
        timezone = TimeZone.init(identifier: defaults.string(forKey: defaultsTimezone)!)!
        recreateZmanimCalendar()
        jewishCalendar = JewishCalendar(workingDate: Date(), timezone: timezone)
        jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
        jewishCalendar.useModernHolidays = true
        GlobalStruct.jewishCalendar = jewishCalendar
        setNextUpcomingZman()
        updateZmanimList()
    }
    
    func resolveElevation() {
        if self.defaults.object(forKey: "elevation" + self.locationName) != nil {//if we have been here before, use the elevation saved for this location
            self.elevation = self.defaults.double(forKey: "elevation" + self.locationName)
        } else {//we have never been here before, get the elevation from online
            if self.defaults.bool(forKey: "useElevation") && !self.defaults.bool(forKey: "LuachAmudeiHoraah") {
                self.getElevationFromOnline()
            } else {
                self.elevation = 0//undo any previous values
            }
        }
        if locationName.isEmpty {
            locationName = "Lat: " + String(lat) + " Long: " + String(long)
            if defaults.bool(forKey: "setElevationToLastKnownLocation") {
                self.elevation = self.defaults.double(forKey: "elevation" + (defaults.string(forKey: "lastKnownLocation") ?? ""))
            }
        }
    }
    
    func syncOldDefaults() {
        let oldDefaults = UserDefaults.standard

        if oldDefaults.bool(forKey: "hasBeenSynced") {
            return
        }
        
        if oldDefaults.object(forKey: "isSetup") != nil {
            for (key, value) in oldDefaults.dictionaryRepresentation() {
                defaults.set(value, forKey: key)
            }
        }
        
        oldDefaults.setValue(true, forKey: "hasBeenSynced")
    }
    
    @objc func labelTapped() {
        if shabbatMode {
            ShabbatModeBanner.isHidden = true
        } else {
            ShabbatModeBanner.isHidden = false
        }
    }
    
    func setBooleansForNotifications() {
        defaults.set(false, forKey: "showDayOfOmer")
        defaults.set(true, forKey: "roundUpRT")
        defaults.set(false, forKey: "zmanim_notifications")
        defaults.set(false, forKey: "zmanim_notifications_on_shabbat")
        
        defaults.set(false, forKey: "NotifyAlot Hashachar")
        defaults.set(false, forKey: "NotifyTalit And Tefilin")
        defaults.set(false, forKey: "NotifySunrise")
        defaults.set(true, forKey: "NotifySof Zman Shma MGA")
        defaults.set(true, forKey: "NotifySof Zman Shma GRA")
        defaults.set(true, forKey: "NotifySof Zman Tefila")
        defaults.set(true, forKey: "NotifyAchilat Chametz")
        defaults.set(true, forKey: "NotifyBiur Chametz")
        defaults.set(false, forKey: "NotifyChatzot")
        defaults.set(false, forKey: "NotifyMincha Gedolah")
        defaults.set(false, forKey: "NotifyMincha Ketana")
        defaults.set(false, forKey: "NotifyPlag HaMincha Yalkut Yosef")
        defaults.set(false, forKey: "NotifyPlag HaMincha Halacha Berurah")
        defaults.set(true, forKey: "NotifyCandle Lighting")
        defaults.set(true, forKey: "NotifySunset")
        defaults.set(true, forKey: "NotifyTzeit Hacochavim")
        defaults.set(true, forKey: "NotifyTzeit Hacochavim (Stringent)")
        defaults.set(true, forKey: "NotifyFast Ends")
        defaults.set(true, forKey: "NotifyFast Ends (Stringent)")
        defaults.set(false, forKey: "NotifyShabbat Ends")
        defaults.set(false, forKey: "NotifyRabbeinu Tam")
        defaults.set(false, forKey: "NotifyChatzot Layla")
        
        defaults.set(-1, forKey: "Alot Hashachar")
        defaults.set(-1, forKey: "Talit And Tefilin")
        defaults.set(-1, forKey: "Sunrise")
        defaults.set(15, forKey: "Sof Zman Shma MGA")
        defaults.set(15, forKey: "Sof Zman Shma GRA")
        defaults.set(15, forKey: "Sof Zman Tefila")
        defaults.set(15, forKey: "Achilat Chametz")
        defaults.set(15, forKey: "Biur Chametz")
        defaults.set(20, forKey: "Chatzot")
        defaults.set(-1, forKey: "Mincha Gedolah")
        defaults.set(-1, forKey: "Mincha Ketana")
        defaults.set(-1, forKey: "Plag HaMincha Yalkut Yosef")
        defaults.set(-1, forKey: "Plag HaMincha Halacha Berurah")
        defaults.set(15, forKey: "Candle Lighting")
        defaults.set(15, forKey: "Sunset")
        defaults.set(15, forKey: "Tzeit Hacochavim")
        defaults.set(15, forKey: "Tzeit Hacochavim (Stringent)")
        defaults.set(15, forKey: "Fast Ends")
        defaults.set(15, forKey: "Fast Ends (Stringent)")
        defaults.set(-1, forKey: "Shabbat Ends")
        defaults.set(0, forKey: "Rabbeinu Tam")
        defaults.set(-1, forKey: "Chatzot Layla")
    }
    
    @objc func createBackgroundThreadForNextUpcomingZman() {
        setNextUpcomingZman()
        updateZmanimList()
        let calendar = Calendar.current
        let timeInterval = calendar.dateComponents([.second], from: Date(), to: nextUpcomingZman!).second!
        timerForNextZman = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval + 1), target: self, selector: #selector(createBackgroundThreadForNextUpcomingZman), userInfo: nil, repeats: false)
    }
    
    func checkIfUserIsInIsrael() {
        if defaults.bool(forKey: "neverAskInIsrael") {
            return
        }
        if !defaults.bool(forKey: "inIsrael") && timezone.identifier == "Asia/Jerusalem" {
            let alertController = UIAlertController(title: "Are you in Israel now?".localized(), message: "If you are in Israel, please confirm below.".localized(), preferredStyle: .alert)

            let yesAction = UIAlertAction(title: "Yes".localized(), style: .default) { (_) in
                self.defaults.set(true, forKey: "inIsrael")
                self.defaults.set(false, forKey: "LuachAmudeiHoraah")
                self.jewishCalendar.inIsrael = true
                GlobalStruct.jewishCalendar.inIsrael = self.jewishCalendar.inIsrael
                self.updateZmanimList()
            }

            alertController.addAction(yesAction)
            
            let noAction = UIAlertAction(title: "No".localized(), style: .default) { (_) in
                self.defaults.set(false, forKey: "inIsrael")
                self.jewishCalendar.inIsrael = false
                GlobalStruct.jewishCalendar.inIsrael = self.jewishCalendar.inIsrael
                self.updateZmanimList()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyboard.instantiateViewController(withIdentifier: "calendarChooser") as! CalendarViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true)
            }

            alertController.addAction(noAction)
            
            let noAskAction = UIAlertAction(title: "Do Not Ask Again".localized(), style: .default) { (_) in
                self.defaults.set(true, forKey: "neverAskInIsrael")
            }

            alertController.addAction(noAskAction)

            present(alertController, animated: true, completion: nil)
        }
        
        if defaults.bool(forKey: "inIsrael") && timezone.identifier != "Asia/Jerusalem" {
            let alertController = UIAlertController(title: "Have you left Israel?".localized(), message: "If you have left Israel, please confirm below.".localized(), preferredStyle: .alert)

            let yesAction = UIAlertAction(title: "Yes".localized(), style: .default) { (_) in
                self.defaults.set(false, forKey: "inIsrael")
                self.jewishCalendar.inIsrael = false
                GlobalStruct.jewishCalendar.inIsrael = self.jewishCalendar.inIsrael
                self.updateZmanimList()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyboard.instantiateViewController(withIdentifier: "calendarChooser") as! CalendarViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true)
            }

            alertController.addAction(yesAction)
            
            let noAction = UIAlertAction(title: "No".localized(), style: .default) { (_) in
                self.defaults.set(true, forKey: "inIsrael")
                self.jewishCalendar.inIsrael = true
                GlobalStruct.jewishCalendar.inIsrael = self.jewishCalendar.inIsrael
                self.updateZmanimList()
            }

            alertController.addAction(noAction)
            
            let noAskAction = UIAlertAction(title: "Do Not Ask Again".localized(), style: .default) { (_) in
                self.defaults.set(true, forKey: "neverAskInIsrael")
            }

            alertController.addAction(noAskAction)

            present(alertController, animated: true, completion: nil)
        }
    }
    
    func checkIfTablesNeedToBeUpdated() {
        if defaults.object(forKey: "chaitablesLink" + locationName) == nil || askedToUpdateTablesAlready {
            return
        }
        let chaitables = ChaiTables(locationName: locationName, jewishCalendar: jewishCalendar, defaults: defaults)
        if chaitables.getVisibleSurise(forDate: userChosenDate) == nil {
            let alert = UIAlertController(title: "Chaitables out of date".localized(), message: "The current hebrew year is out of scope for the visible sunrise times that were downloaded from Chaitables. Would you like to download the tables for this hebrew year?".localized(), preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { [weak alert] (_) in
                let oldLink = self.defaults.string(forKey: "chaitablesLink" + self.locationName)
                let hebrewYear = String(self.jewishCalendar.getJewishYear())
                let pattern = "&cgi_yrheb=\\d{4}"
                let newLink = oldLink?.replacingOccurrences(of: pattern, with: "&cgi_yrheb=" + hebrewYear, options: .regularExpression)
                let scraper = ChaiTablesScraper(link: newLink ?? "", locationName: self.locationName, jewishYear: self.jewishCalendar.getJewishYear(), defaults: self.defaults)
                scraper.scrape {
                    self.updateZmanimList()
                    alert?.dismiss(animated: true)
                }
            })
            
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: { [weak alert] (_) in
                alert?.dismiss(animated: true)
            })
            
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true)
            askedToUpdateTablesAlready = true
        }
    }
    
    func showSetup() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "inIsrael") as! InIsraelViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true) {
            self.jewishCalendar.inIsrael = self.defaults.bool(forKey: "inIsrael")
            self.updateZmanimList()
        }
        defaults.set(true, forKey: "setupShown")
    }
    
    func getElevationFromOnline() {
        var intArray: [Int] = []
        var e1:Int = 0
        var e2:Int = 0
        var e3:Int = 0
        let group = DispatchGroup()
        group.enter()
        let geocoder = LSGeoLookup(withUserID: "Elyahu41")
        geocoder.findElevationGtopo30(latitude: lat, longitude: long) {
            elevation in
            if let elevation = elevation {
                e1 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.enter()
        geocoder.findElevationSRTM3(latitude: lat, longitude: long) {
            elevation in
            if let elevation = elevation {
                e2 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.enter()
        geocoder.findElevationAstergdem(latitude: lat, longitude: long) {
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
            self.elevation = Double(text) ?? 0
            self.defaults.set(self.elevation, forKey: "elevation" + self.locationName)
            self.recreateZmanimCalendar()
            self.jewishCalendar = JewishCalendar(workingDate: Date(), timezone: self.timezone)
            self.jewishCalendar.inIsrael = self.defaults.bool(forKey: "inIsrael")
            self.jewishCalendar.useModernHolidays = true
            self.setNextUpcomingZman()
            self.updateZmanimList()
        }
    }
    
    func startShabbatMode() {
        shabbatMode = true
        userChosenDate = Date()
        syncCalendarDates()
        updateZmanimList()
        prevDayButton.isEnabled = false
        calendarButton.isEnabled = false
        nextDayButton.isEnabled = false
        ShabbatModeBanner.speed = .rate(15)
        ShabbatModeBanner.animationCurve = .linear
        setShabbatBannerColors(isFirstTime:true)
        ShabbatModeBanner.isHidden = false
        startBackgroundScrollingThread()
        scheduleTimer()//to update zmanim
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func scheduleTimer() {
        let calendar = Calendar.current
        let currentDate = Date()
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate)
        dateComponents.day! += 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 2
        let targetDate = calendar.date(from: dateComponents)!

        let timeInterval = calendar.dateComponents([.second], from: currentDate, to: targetDate).second!
        timerForShabbatMode = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(updateZmanimListWithNewDate), userInfo: nil, repeats: true)
    }
    
    @objc func updateZmanimListWithNewDate() {
        userChosenDate = Date()
        syncCalendarDates()
        setShabbatBannerColors(isFirstTime: false)
        setNextUpcomingZman()
        updateZmanimList()
    }
    
    func startBackgroundScrollingThread() {
        let max = self.zmanimTableView.contentSize.height - self.zmanimTableView.frame.height
        var height = CGFloat(exactly: 0)
        
        shouldScroll = true  // Flag to control scrolling
        
        DispatchQueue.global(qos: .background).async {
            while self.shabbatMode {
                while self.shabbatMode && height! < max && self.shouldScroll {
                    DispatchQueue.main.async {
                        if self.shabbatMode {
                            self.zmanimTableView.contentOffset = CGPoint(x: self.zmanimTableView.contentOffset.x, y: height!)
                            height! += 1
                        }
                    }
                    Thread.sleep(forTimeInterval: 0.01)
                }
                
                while self.shabbatMode && height! >= 0 && self.shouldScroll {
                    DispatchQueue.main.async {
                        if self.shabbatMode {
                            self.zmanimTableView.contentOffset = CGPoint(x: self.zmanimTableView.contentOffset.x, y: height!)
                            height! -= 1
                        }
                    }
                    Thread.sleep(forTimeInterval: 0.01)
                }
            }
        }
    }
    
    func endShabbatMode() {
        shabbatMode = false
        prevDayButton.isEnabled = true
        calendarButton.isEnabled = true
        nextDayButton.isEnabled = true
        ShabbatModeBanner.isHidden = true
        updateZmanimList()
        timerForShabbatMode?.invalidate()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func setShabbatBannerColors(isFirstTime:Bool) {
        if isFirstTime {
            jewishCalendar.forward()
        }
        
        let isShabbat = jewishCalendar.getDayOfWeek() == 7
        
        var bannerText = ""
        
        switch jewishCalendar.getYomTovIndex() {
        case JewishCalendar.PESACH:
            for _ in 0...4 {
                bannerText += "PESACH".localized()
                if isShabbat {
                    bannerText += "/SHABBAT".localized()
                }
                bannerText += "MODE          ".localized()
            }
            ShabbatModeBanner.backgroundColor = .init(named:"light_yellow")
            ShabbatModeBanner.textColor = .black
        case JewishCalendar.SHAVUOS:
            for _ in 0...4 {
                bannerText += "SHAVUOT".localized()
                if isShabbat {
                    bannerText += "/SHABBAT".localized()
                }
                bannerText += "MODE          ".localized()
            }
            ShabbatModeBanner.backgroundColor = .systemBlue
            ShabbatModeBanner.textColor = .white
        case JewishCalendar.SUCCOS:
            for _ in 0...4 {
                bannerText += "SUCCOT"
                if isShabbat {
                    bannerText += "/SHABBAT".localized()
                }
                bannerText += "MODE          ".localized()
            }
            ShabbatModeBanner.backgroundColor = .systemGreen
            ShabbatModeBanner.textColor = .black
        case JewishCalendar.SHEMINI_ATZERES:
            for _ in 0...4 {
                bannerText += "SHEMINI ATZERET".localized()
                if isShabbat {
                    bannerText += "/SHABBAT".localized()
                }
                bannerText += "MODE          ".localized()
            }
            ShabbatModeBanner.backgroundColor = .systemGreen
            ShabbatModeBanner.textColor = .black
        case JewishCalendar.SIMCHAS_TORAH:
            for _ in 0...4 {
                bannerText += "SIMCHAT TORAH".localized()
                if isShabbat {
                    bannerText += "/SHABBAT".localized()
                }
                bannerText += "MODE          ".localized()
            }
            ShabbatModeBanner.backgroundColor = .green
            ShabbatModeBanner.textColor = .black
        case JewishCalendar.ROSH_HASHANA:
            for _ in 0...4 {
                bannerText += "ROSH HASHANA".localized()
                if isShabbat {
                    bannerText += "/SHABBAT".localized()
                }
                bannerText += "MODE          ".localized()
            }
            ShabbatModeBanner.backgroundColor = .red
            ShabbatModeBanner.textColor = .white
        case JewishCalendar.YOM_KIPPUR:
            for _ in 0...4 {
                bannerText += "YOM KIPPUR".localized()
                if isShabbat {
                    bannerText += "/SHABBAT".localized()
                }
                bannerText += "MODE          ".localized()
            }
            ShabbatModeBanner.backgroundColor = .white
            ShabbatModeBanner.textColor = .black
        default:
            bannerText = "Shabbat Mode          Shabbat Mode          Shabbat Mode           Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          ".localized()
            ShabbatModeBanner.backgroundColor = .init(named:"dark_blue")
            ShabbatModeBanner.textColor = .white
        }
        
        ShabbatModeBanner.text = bannerText
        
        if isFirstTime {
            jewishCalendar.back()
        }
    }
    
    func setNextUpcomingZman() {
        var theZman: Date? = nil
        var zmanim = Array<ZmanListEntry>()
        var today = Date()
        
        today = today.advanced(by: -86400)//yesterday
        jewishCalendar.workingDate = today
        zmanimCalendar.workingDate = today
        zmanim = addZmanim(list: zmanim)
        
        today = today.advanced(by: 86400)//today
        jewishCalendar.workingDate = today
        zmanimCalendar.workingDate = today
        zmanim = addZmanim(list: zmanim)

        today = today.advanced(by: 86400)//tomorrow
        jewishCalendar.workingDate = today
        zmanimCalendar.workingDate = today
        zmanim = addZmanim(list: zmanim)

        zmanimCalendar.workingDate = userChosenDate//reset
        jewishCalendar.workingDate = userChosenDate//reset
        
        for entry in zmanim {
            let zman = entry.zman
            if zman != nil {
                if zman! > Date() && (theZman == nil || zman! < theZman!) {
                    theZman = zman
                }
            }
        }
        nextUpcomingZman = theZman
    }
    
    func addZmanim(list:Array<ZmanListEntry>) -> Array<ZmanListEntry> {
        if defaults.bool(forKey: "LuachAmudeiHoraah") {
            return addAmudeiHoraahZmanim(list:list)
        }
        var temp = list
        let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        if jewishCalendar.isTaanis()
            && jewishCalendar.getYomTovIndex() != JewishCalendar.TISHA_BEAV
            && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.getAlos72Zmanis(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.getAlos72Zmanis(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.getMisheyakir66MinutesZmanit(), isZman: true))
        let chaitables = ChaiTables(locationName: locationName, jewishCalendar: jewishCalendar, defaults: defaults)
        let visibleSurise = chaitables.getVisibleSurise(forDate: userChosenDate)
        if visibleSurise != nil {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true, isVisibleSunriseZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
        }
        if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.getSofZmanShmaMGA72MinutesZmanis(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
        if jewishCalendar.getYomTovIndex() == JewishCalendar.EREV_PESACH {
            temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman:zmanimCalendar.getSofZmanTfilaMGA72MinutesZmanis(), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.getSofZmanTfilaGRA(), isZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman:zmanimCalendar.getSofZmanBiurChametzMGA72MinutesZmanis(), isZman: true, isNoteworthyZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.getSofZmanTfilaGRA(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman:zmanimCalendar.getChatzosIfHalfDayNil(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman:zmanimCalendar.getMinchaGedolaGreaterThan30(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman:zmanimCalendar.getMinchaKetana(), isZman: true))
        if defaults.integer(forKey: "plagOpinion") == 1 || defaults.object(forKey: "plagOpinion") == nil {
            temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString(), zman:zmanimCalendar.getPlagHaminchaYalkutYosef(), isZman: true))
        } else if defaults.integer(forKey: "plagOpinion") == 2 {
            temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.getPlagHamincha(), isZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.getPlagHamincha(), isZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedYalkutYosefString(), zman:zmanimCalendar.getPlagHaminchaYalkutYosef(), isZman: true))
        }
        if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.getDayOfWeek() == 6 {
            zmanimCalendar.candleLightingOffset = 20
            if defaults.object(forKey: "candleLightingOffset") != nil {
                zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
            }
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman:zmanimCalendar.getCandleLighting(), isZman: true, isNoteworthyZman: true))
        }
        if defaults.bool(forKey: "showWhenShabbatChagEnds") {
            if jewishCalendar.getDayOfWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni() {
                jewishCalendar.forward()
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go to the next day
                if !(jewishCalendar.getDayOfWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni()) {//only add if shabbat/chag actually ends
                    if defaults.bool(forKey: "showRegularWhenShabbatChagEnds") {
                        zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
                        if defaults.object(forKey: "shabbatOffset") != nil {
                            zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
                        }
                        if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + " (" + String(Int(zmanimCalendar.ateretTorahSunsetOffset)) + ")" + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
                        } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
                        } else {
                            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
                        }
                    }
                    if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                        temp.append(ZmanListEntry(title: zmanimNames.getRTString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzais72Zmanis(), isZman: true))
                    }
                }
                jewishCalendar.back()
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
            }
        }
        jewishCalendar.forward()
        if jewishCalendar.getYomTovIndex() == JewishCalendar.TISHA_BEAV {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman:zmanimCalendar.getElevationAdjustedSunset(), isZman: true))
        }
        jewishCalendar.back()
        temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.getElevationAdjustedSunset(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.getTzais13Point5MinutesZmanis(), isZman: true))
        if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.getDayOfWeek() != 6 {
            if jewishCalendar.getDayOfWeek() == 7 {
                zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
                if defaults.object(forKey: "shabbatOffset") != nil {
                    zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
                }
                if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                    temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
                } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                    temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
                } else {
                    temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
                }
            } else {// just yom tov
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzais13Point5MinutesZmanis(), isZman: true, isNoteworthyZman: true))
            }
        }
        if jewishCalendar.isTaanis() && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisAteretTorah(minutes: 20), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.getTzaisAteretTorah(minutes: 30), isZman: true, isNoteworthyZman: true))
        } else if defaults.bool(forKey: "showTzeitLChumra") {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman: zmanimCalendar.getTzaisAteretTorah(minutes: 20), isZman: true))
        }
        if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
            zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
            if defaults.object(forKey: "shabbatOffset") != nil {
                zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
            }
            if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + " (" + String(Int(zmanimCalendar.ateretTorahSunsetOffset)) + ")", zman:zmanimCalendar.getTzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
            } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            } else {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
            }
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.getTzais72Zmanis(), isZman: true, isNoteworthyZman: true, isRTZman: true))
            var index = 0
            for var zman in temp {
                if zman.title == zmanimNames.getTzaitHacochavimString() || zman.title == zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString() {
                    zman.shouldBeDimmed = true
                    temp.remove(at: index)
                    temp.insert(zman, at: index)
                }
                index+=1
            }
        }
        if defaults.bool(forKey: "alwaysShowRT") {
            if !(jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting()) {
                temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.getTzais72Zmanis(), isZman: true, isNoteworthyZman: true, isRTZman: true))
            }
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.getSolarMidnightIfSunTransitNil(), isZman: true))
        return temp
    }
    
    func addAmudeiHoraahZmanim(list:Array<ZmanListEntry>) -> Array<ZmanListEntry> {
        var temp = list
        let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        if jewishCalendar.isTaanis()
            && jewishCalendar.getYomTovIndex() != JewishCalendar.TISHA_BEAV
            && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.getAlosAmudeiHoraah(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.getAlosAmudeiHoraah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.getMisheyakirAmudeiHoraah(), isZman: true))
        let chaitables = ChaiTables(locationName: locationName, jewishCalendar: jewishCalendar, defaults: defaults)
        let visibleSurise = chaitables.getVisibleSurise(forDate: userChosenDate)
        if visibleSurise != nil {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true, isVisibleSunriseZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
        }
        if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.getSofZmanShmaMGA72MinutesZmanisAmudeiHoraah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
        if jewishCalendar.getYomTovIndex() == JewishCalendar.EREV_PESACH {
            temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman:zmanimCalendar.getSofZmanAchilatChametzAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.getSofZmanTfilaGRA(), isZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman:zmanimCalendar.getSofZmanBiurChametzMGAAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.getSofZmanTfilaGRA(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman:zmanimCalendar.getChatzosIfHalfDayNil(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman:zmanimCalendar.getMinchaGedolaGreaterThan30(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman: zmanimCalendar.getMinchaKetana(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.getPlagHamincha(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedYalkutYosefString(), zman:zmanimCalendar.getPlagHaminchaYalkutYosefAmudeiHoraah(), isZman: true))
        if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.getDayOfWeek() == 6 {
            zmanimCalendar.candleLightingOffset = 20
            if defaults.object(forKey: "candleLightingOffset") != nil {
                zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
            }
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman:zmanimCalendar.getCandleLighting(), isZman: true, isNoteworthyZman: true))
        }
        if defaults.bool(forKey: "showWhenShabbatChagEnds") {
            if jewishCalendar.getDayOfWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni() {
                jewishCalendar.forward()
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go to the next day
                if !(jewishCalendar.getDayOfWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni()) {//only add if shabbat/chag actually ends
                    if defaults.bool(forKey: "showRegularWhenShabbatChagEnds") {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true))
                    }
                    if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                        temp.append(ZmanListEntry(title: zmanimNames.getRTString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzais72ZmanisAmudeiHoraahLkulah(), isZman: true))
                    }
                }
                jewishCalendar.back()
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
            }
        }
        jewishCalendar.forward()
        if jewishCalendar.getYomTovIndex() == JewishCalendar.TISHA_BEAV {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman:zmanimCalendar.getElevationAdjustedSunset(), isZman: true))
        }
        jewishCalendar.back()
        temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.getSeaLevelSunset(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.getTzaisAmudeiHoraah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.getTzaisAmudeiHoraahLChumra(), isZman: true))
        if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.getDayOfWeek() != 6 {
            if jewishCalendar.getDayOfWeek() == 7 {
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            } else {// just yom tov
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisAmudeiHoraahLChumra(), isZman: true, isNoteworthyZman: true))
            }
        }
        if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.getTzais72ZmanisAmudeiHoraahLkulah(), isZman: true, isNoteworthyZman: true, isRTZman: true))
            var index = 0
            for var zman in temp {
                if zman.title == zmanimNames.getTzaitHacochavimString() || zman.title == zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString() {
                    zman.shouldBeDimmed = true
                    temp.remove(at: index)
                    temp.insert(zman, at: index)
                }
                index+=1
            }
        }
        if defaults.bool(forKey: "alwaysShowRT") {
            if !(jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting()) {
                temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.getTzais72ZmanisAmudeiHoraahLkulah(), isZman: true, isNoteworthyZman: true, isRTZman: true))
            }
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.getSolarMidnightIfSunTransitNil(), isZman: true))
        return temp
    }
    
    func getUserLocation() {
        let concurrentQueue = DispatchQueue(label: "mainApp", attributes: .concurrent)

        LocationManager.shared.getUserLocation {
            location in concurrentQueue.async { [self] in
                lat = location.coordinate.latitude
                long = location.coordinate.longitude
                timezone = TimeZone.current
                recreateZmanimCalendar()
                defaults.set(timezone.identifier, forKey: "timezone")
                defaults.set(true, forKey: "isSetup")
                defaults.set(false, forKey: "useZipcode")
                defaults.set(false, forKey: "useAdvanced")
                useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                LocationManager.shared.resolveLocationName(with: location) { [self] locationName in
                    self.locationName = locationName ?? ""
                    resolveElevation()
                    recreateZmanimCalendar()
                    jewishCalendar = JewishCalendar(workingDate: Date(), timezone: timezone)
                    jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
                    jewishCalendar.useModernHolidays = true
                    GlobalStruct.jewishCalendar = jewishCalendar
                    setNextUpcomingZman()
                    updateZmanimList()
                    NotificationManager.instance.requestAuthorization()
                    NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
                    if self.wcSession != nil {
                        if self.wcSession.isPaired {
                            if self.wcSession.isWatchAppInstalled {
                                self.wcSession.sendMessage(self.getSettingsDictionary(), replyHandler: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func useLocation(location1:Bool, location2:Bool, location3:Bool, location4:Bool, location5:Bool) {
        defaults.setValue(location1, forKey: "useLocation1")
        defaults.setValue(location2, forKey: "useLocation2")
        defaults.setValue(location3, forKey: "useLocation3")
        defaults.setValue(location4, forKey: "useLocation4")
        defaults.setValue(location5, forKey: "useLocation5")
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if shabbatMode {
            shouldScroll = false  // Pause scrolling
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                self.shouldScroll = true
            }
        }
    }
    
    @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if !shabbatMode {
            if gestureRecognizer.state == .ended {
                if gestureRecognizer.direction == .left {
                    nextDayButton((Any).self)
                }
                if gestureRecognizer.direction == .right {
                    prevDayButton((Any).self)
                }
            }
        } else {
            shouldScroll = false
        }
    }
    
    func updateZmanimList() {
        zmanimList = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, yyyy"
        dateFormatter.timeZone = timezone
        zmanimList.append(ZmanListEntry(title: locationName))
        var date = dateFormatter.string(from: userChosenDate)
                
        let hDateFormatter = DateFormatter()
        hDateFormatter.calendar = Calendar(identifier: .hebrew)
        hDateFormatter.dateFormat = "d MMMM, yyyy"
        var hebrewDate = hDateFormatter.string(from: userChosenDate)
            .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
            .replacingOccurrences(of: "Tamuz", with: "Tammuz")
        
        if Locale.isHebrewLocale() {
            let hebrewDateFormatter = HebrewDateFormatter()
            hebrewDateFormatter.hebrewFormat = true
            hebrewDate = hebrewDateFormatter.format(jewishCalendar: jewishCalendar)
        }
        
        if Calendar.current.isDateInToday(userChosenDate) {
            date += "   ▼   " + hebrewDate
        } else {
            date += "       " + hebrewDate
        }
        zmanimList.append(ZmanListEntry(title:date))
        //forward jewish calendar to saturday
        while jewishCalendar.getDayOfWeek() != 7 {
            jewishCalendar.forward()
        }
        let hebrewDateFormatter = HebrewDateFormatter()
        hebrewDateFormatter.hebrewFormat = true
        //now that we are on saturday, check the parasha
        let specialParasha = hebrewDateFormatter.formatSpecialParsha(jewishCalendar: jewishCalendar)
        var parasha = hebrewDateFormatter.formatParsha(parsha: jewishCalendar.getParshah())
        
        if !specialParasha.isEmpty {
            parasha += " / " + specialParasha
        }
        if !parasha.isEmpty {
            zmanimList.append(ZmanListEntry(title:parasha))
        } else {
            zmanimList.append(ZmanListEntry(title:"No Weekly Parasha".localized()))
        }
        syncCalendarDates()//reset
        dateFormatter.dateFormat = "EEEE"
        hebrewDateFormatter.setLongWeekFormat(longWeekFormat: true)
        if Locale.isHebrewLocale() {
            zmanimList.append(ZmanListEntry(title:dateFormatter.string(from: zmanimCalendar.workingDate)))
        } else {
            zmanimList.append(ZmanListEntry(title:dateFormatter.string(from: zmanimCalendar.workingDate) + " / " + "יום " + hebrewDateFormatter.formatDayOfWeek(jewishCalendar: jewishCalendar)))
        }
        hebrewDateFormatter.hebrewFormat = false
        let specialDay = jewishCalendar.getSpecialDay(addOmer:true)
        if !specialDay.isEmpty {
            zmanimList.append(ZmanListEntry(title:specialDay))
        }
        if jewishCalendar.is3Weeks() {
            if jewishCalendar.is9Days() {
                if jewishCalendar.isShevuahShechalBo() {
                    zmanimList.append(ZmanListEntry(title: "Shevuah Shechal Bo".localized()))
                } else {
                    zmanimList.append(ZmanListEntry(title: "Nine Days".localized()))
                }
            } else {
                zmanimList.append(ZmanListEntry(title: "Three Weeks".localized()))
            }
        }
        if jewishCalendar.getYomTovIndex() == JewishCalendar.ROSH_HASHANA && jewishCalendar.isShmitaYear() {
            zmanimList.append(ZmanListEntry(title: "This year is a shmita year".localized()))
        }
        let music = jewishCalendar.isOKToListenToMusic()
        if !music.isEmpty {
            zmanimList.append(ZmanListEntry(title: music))
        }
        let hallel = jewishCalendar.getHallelOrChatziHallel()
        if !hallel.isEmpty {
            zmanimList.append(ZmanListEntry(title: hallel))
        }
        let ulChaparatPesha = jewishCalendar.getIsUlChaparatPeshaSaid()
        if !ulChaparatPesha.isEmpty {
            zmanimList.append(ZmanListEntry(title: ulChaparatPesha))
        }
        zmanimList.append(ZmanListEntry(title:jewishCalendar.getTachanun()))
        let bircatHelevana = jewishCalendar.getBirchatLevanaStatus()
        if !bircatHelevana.isEmpty {
            zmanimList.append(ZmanListEntry(title: bircatHelevana))
        }
        if jewishCalendar.isBirkasHachamah() {
            zmanimList.append(ZmanListEntry(title: "Birchat HaChamah is said today".localized()))
        }
        if Locale.isHebrewLocale() {
            dateFormatter.dateFormat = "H:mm"
        } else {
            dateFormatter.dateFormat = "h:mm aa"
        }
        dateFormatter.timeZone = timezone
        let tekufaSetting = defaults.integer(forKey: "tekufaOpinion")
        if tekufaSetting == 1 {
            let tekufa = jewishCalendar.getTekufaAsDate()
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        } else if tekufaSetting == 2 {
            let tekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        } else {
            let tekufa = jewishCalendar.getTekufaAsDate()
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
            
            let tekufaAH = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if tekufaAH != nil {
                if Calendar.current.isDate(tekufaAH!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufaAH!)))
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForAHTekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if checkTomorrowForAHTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForAHTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForAHTekufa!)))
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        }
        
        zmanimList = addZmanim(list: zmanimList)
        
        hebrewDateFormatter.hebrewFormat = true
        hebrewDateFormatter.useGershGershayim = false
        let dafYomi = jewishCalendar.getDafYomiBavli()
        if dafYomi != nil {
            zmanimList.append(ZmanListEntry(title:"Daf Yomi: ".localized() + hebrewDateFormatter.formatDafYomiBavli(daf: dafYomi!)))
        }
        let dateString = "1980-02-02"//Yerushalmi start date
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let yerushalmiYomi = YerushalmiYomiCalculator.getDafYomiYerushalmi(jewishCalendar: jewishCalendar)
        if let targetDate = dateFormatter.date(from: dateString) {
            let comparisonResult = targetDate.compare(userChosenDate)
            if comparisonResult == .orderedDescending {
                print("The target date is before Feb 2, 1980.")
            } else if comparisonResult == .orderedAscending {
                if yerushalmiYomi != nil {
                    zmanimList.append(ZmanListEntry(title:"Yerushalmi Vilna Yomi: ".localized() + hebrewDateFormatter.formatDafYomiYerushalmi(daf: yerushalmiYomi)))
                } else {
                    zmanimList.append(ZmanListEntry(title:"No Yerushalmi Vilna Yomi".localized()))
                }
            }
        }
        zmanimList.append(ZmanListEntry(title:jewishCalendar.getIsMashivHaruchOrMoridHatalSaid() + " / " + jewishCalendar.getIsBarcheinuOrBarechAleinuSaid()))
        if !shabbatMode {
            var siddurEntry = ZmanListEntry(title: "Daily Siddur".localized())
            if (jewishCalendar.getYomTovIndex() == JewishCalendar.TU_BESHVAT ||
                                (jewishCalendar.getUpcomingParshah() == JewishCalendar.Parsha.BESHALACH &&
                                 jewishCalendar.getDayOfWeek() == 3)) {// if disclaimers will be shown in siddur
                siddurEntry.title = siddurEntry.title.appending("*")
            }
            zmanimList.append(siddurEntry)
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        if defaults.bool(forKey: "LuachAmudeiHoraah") {
            zmanimList.append(ZmanListEntry(title:"Shaah Zmanit GRA: ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getShaahZmanisGra() / 1000)) ?? "XX:XX") + " / " + "MGA: ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getTemporalHour(startOfDay: zmanimCalendar.getAlosAmudeiHoraah(), endOfDay: zmanimCalendar.getTzais72ZmanisAmudeiHoraah()) / 1000)) ?? "XX:XX")))
        } else {
            zmanimList.append(ZmanListEntry(title:"Shaah Zmanit GRA: ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getShaahZmanisGra() / 1000)) ?? "XX:XX") + " / " + "MGA: ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getShaahZmanis72MinutesZmanis() / 1000)) ?? "XX:XX")))
        }
        zmanimTableView.reloadData()
    }
    
    func getShabbatAndOrChag() -> String {
        if (defaults.bool(forKey: "isZmanimInHebrew")) {
            if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.getDayOfWeek() == 7 {
                return "\u{05E9}\u{05D1}\u{05EA}/\u{05D7}\u{05D2}"
            } else if jewishCalendar.getDayOfWeek() == 7 {
                return "\u{05E9}\u{05D1}\u{05EA}"
            } else {
                return "\u{05D7}\u{05D2}"
            }
        } else {
            if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.getDayOfWeek() == 7 {
                return "Shabbat/Chag";
            } else if jewishCalendar.getDayOfWeek() == 7 {
                return "Shabbat";
            } else {
                return "Chag";
            }
        }
    }
    
    func showZipcodeAlert() {
        let advancedAlert = UIAlertController(title: "Advanced".localized(),
                                              message: "Enter your location's name, latitude, longitude, elevation, and timezone.".localized(), preferredStyle: .alert)
        advancedAlert.addTextField { (textField) in
            textField.placeholder = "Location Name".localized()
        }
        advancedAlert.addTextField { (textField) in
            textField.placeholder = "Latitude".localized()
        }
        advancedAlert.addTextField { (textField) in
            textField.placeholder = "Longitude".localized()
        }
        advancedAlert.addTextField { (textField) in
            textField.placeholder = "Elevation".localized()
        }
        advancedAlert.addTextField { (textField) in
            textField.placeholder = "Timezone e.g. America/New_York"// not going to translate this, as the timezone needs to be in english
        }
        advancedAlert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { [self] UIAlertAction in
            defaults.setValue(true, forKey: "useAdvanced")
            defaults.setValue(false, forKey: "useZipcode")
            useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
            
            let locationName = advancedAlert.textFields![0].text
            let latitude = Double(advancedAlert.textFields![1].text ?? "")
            let longitude = Double(advancedAlert.textFields![2].text ?? "")
            let elevation = Double(advancedAlert.textFields![3].text ?? "")
            let timezone = advancedAlert.textFields![4].text

            if timezone == nil { // don't do anything if the timezone was never filled in
                return
            } else {
                defaults.setValue(locationName, forKey: "advancedLN")
                defaults.setValue(latitude, forKey: "advancedLat")
                defaults.setValue(longitude, forKey: "advancedLong")
                defaults.setValue(elevation, forKey: "elevation".appending(locationName ?? ""))
                defaults.setValue(timezone, forKey: "advancedTimezone")
            }
            setLocation(defaultsLN: "advancedLN", defaultsLat: "advancedLat", defaultsLong: "advancedLong", defaultsTimezone: "advancedTimezone")
            NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
            if wcSession != nil {
                if wcSession.isPaired {
                    if wcSession.isWatchAppInstalled {
                        wcSession.sendMessage(getSettingsDictionary(), replyHandler: nil)
                    }
                }
            }
        }))
        advancedAlert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { UIAlertAction in
            self.dismiss(animated: true)
        }))
        
        let alert = UIAlertController(title: "Location or Search a place?".localized(),
                                      message: "You can choose to use your device's location, or you can search for a place below. It is recommended to use your devices location as this provides more accurate results and it will automatically update your location.".localized(), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Zipcode/Address".localized()
        }
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            //if text is empty, display a message notifying the user:
            if textField?.text == "" {
                let alert = UIAlertController(title: "Error".localized(), message: "Please enter a valid zipcode or address.".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: {_ in
                    self.showZipcodeAlert()
                }))
                self.present(alert, animated: true)
                return
            }
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString((textField?.text)!, in: nil, preferredLocale: .current, completionHandler: { i, j in
                var name = ""
                if i?.first?.locality != nil {
                    if let locality = i?.first?.locality {
                        name += locality
                    }
                }
                if i?.first?.administrativeArea != nil {
                    if let adminRegion = i?.first?.administrativeArea {
                        name += ", \(adminRegion)"
                    }
                }
                if name.isEmpty {
                    name = "No location name info".localized()
                }
                self.locationName = name
                let coordinates = i?.first?.location?.coordinate
                self.lat = coordinates?.latitude ?? 0
                self.long = coordinates?.longitude ?? 0
                self.resolveElevation()
                if i?.first?.timeZone != nil {
                    self.timezone = (i?.first?.timeZone)!
                }
                self.recreateZmanimCalendar()
                self.setNextUpcomingZman()
                self.updateZmanimList()
                self.defaults.set(name, forKey: "locationName")
                self.defaults.set(self.lat, forKey: "lat")
                self.defaults.set(self.long, forKey: "long")
                self.defaults.set(true, forKey: "isSetup")
                self.defaults.set(true, forKey: "useZipcode")
                self.defaults.set(false, forKey: "useAdvanced")
                self.useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                self.defaults.set(self.timezone.identifier, forKey: "timezone")
                self.saveLocation()
                NotificationManager.instance.requestAuthorization()
                NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
                if self.wcSession != nil {
                    if self.wcSession.isPaired {
                        if self.wcSession.isWatchAppInstalled {
                            self.wcSession.sendMessage(self.getSettingsDictionary(), replyHandler: nil)
                        }
                    }
                }
            })
        }))
        if defaults.string(forKey: "location1") ?? "" != "" {
            alert.addAction(UIAlertAction(title: defaults.string(forKey: "location1"), style: .default, handler: { UIAlertAction in
                self.useLocation(location1: true, location2: false, location3: false, location4: false, location5: false)
                self.setLocationAndDisperse(locationName: "location1")
            }))
        }
        if defaults.string(forKey: "location2") ?? "" != "" {
            alert.addAction(UIAlertAction(title: defaults.string(forKey: "location2"), style: .default, handler: { UIAlertAction in
                self.useLocation(location1: false, location2: true, location3: false, location4: false, location5: false)
                self.setLocationAndDisperse(locationName: "location2")
            }))
        }
        if defaults.string(forKey: "location3") ?? "" != "" {
            alert.addAction(UIAlertAction(title: defaults.string(forKey: "location3"), style: .default, handler: { UIAlertAction in
                self.useLocation(location1: false, location2: false, location3: true, location4: false, location5: false)
                self.setLocationAndDisperse(locationName: "location3")
            }))
        }
        if defaults.string(forKey: "location4") ?? "" != "" {
            alert.addAction(UIAlertAction(title: defaults.string(forKey: "location4"), style: .default, handler: { UIAlertAction in
                self.useLocation(location1: false, location2: false, location3: false, location4: true, location5: false)
                self.setLocationAndDisperse(locationName: "location4")
            }))
        }
        if defaults.string(forKey: "location5") ?? "" != "" {
            alert.addAction(UIAlertAction(title: defaults.string(forKey: "location5"), style: .default, handler: { UIAlertAction in
                self.useLocation(location1: false, location2: false, location3: false, location4: false, location5: true)
                self.setLocationAndDisperse(locationName: "location5")
            }))
        }
        alert.addAction(UIAlertAction(title: "Use Location".localized(), style: .default, handler: { UIAlertAction in
            self.getUserLocation()
            self.defaults.set(true, forKey: "isSetup")
        }))
        alert.addAction(UIAlertAction(title: "Advanced".localized(), style: .default, handler: { UIAlertAction in
            self.present(advancedAlert, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { UIAlertAction in
            alert.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveLocation() {
        var setOfLocationNames = Set<String>()
        
        setOfLocationNames.insert(defaults.string(forKey: "location1") ?? "")
        setOfLocationNames.insert(defaults.string(forKey: "location2") ?? "")
        setOfLocationNames.insert(defaults.string(forKey: "location3") ?? "")
        setOfLocationNames.insert(defaults.string(forKey: "location4") ?? "")
        setOfLocationNames.insert(defaults.string(forKey: "location5") ?? "")
        
        if !locationName.isEmpty && !setOfLocationNames.contains(locationName) {
            defaults.setValue(defaults.string(forKey: "location4") ?? "", forKey: "location5")
            defaults.setValue(defaults.double(forKey: "location4Lat"), forKey: "location5Lat")
            defaults.setValue(defaults.double(forKey: "location4Long"), forKey: "location5Long")
            defaults.setValue(defaults.string(forKey: "location4Timezone"), forKey: "location5Timezone")
            
            defaults.setValue(defaults.string(forKey: "location3") ?? "", forKey: "location4")
            defaults.setValue(defaults.double(forKey: "location3Lat"), forKey: "location4Lat")
            defaults.setValue(defaults.double(forKey: "location3Long"), forKey: "location4Long")
            defaults.setValue(defaults.string(forKey: "location3Timezone"), forKey: "location4Timezone")
            
            defaults.setValue(defaults.string(forKey: "location2") ?? "", forKey: "location3")
            defaults.setValue(defaults.double(forKey: "location2Lat"), forKey: "location3Lat")
            defaults.setValue(defaults.double(forKey: "location2Long"), forKey: "location3Long")
            defaults.setValue(defaults.string(forKey: "location2Timezone"), forKey: "location3Timezone")

            defaults.setValue(defaults.string(forKey: "location1") ?? "", forKey: "location2")
            defaults.setValue(defaults.double(forKey: "location1Lat"), forKey: "location2Lat")
            defaults.setValue(defaults.double(forKey: "location1Long"), forKey: "location2Long")
            defaults.setValue(defaults.string(forKey: "location1Timezone"), forKey: "location2Timezone")

            defaults.setValue(locationName, forKey: "location1")
            defaults.setValue(lat, forKey: "location1Lat")
            defaults.setValue(long, forKey: "location1Long")
            defaults.setValue(timezone.identifier, forKey: "location1Timezone")
        }
    }
    
    func setLocationAndDisperse(locationName:String) {
        setLocation(defaultsLN: locationName, defaultsLat: locationName.appending("Lat"), defaultsLong: locationName.appending("Long"), defaultsTimezone: locationName.appending("Timezone"))
        NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
        if wcSession != nil {
            if wcSession.isPaired {
                if wcSession.isWatchAppInstalled {
                    wcSession.sendMessage(getSettingsDictionary(), replyHandler: nil)
                }
            }
        }
    }
    
    @objc func didGetNotification(_ notification: Notification) {
        if notification.object != nil {
            let amount = notification.object as! String
            elevation = NumberFormatter().number(from: amount)!.doubleValue
            defaults.set(elevation, forKey: "elevation" + locationName)
        }
        recreateZmanimCalendar()
        setNextUpcomingZman()
        updateZmanimList()
    }
    
    public func recreateZmanimCalendar() {
        if defaults.bool(forKey: "LuachAmudeiHoraah") {
            zmanimCalendar = ComplexZmanimCalendar(location: GeoLocation(locationName: locationName, latitude: lat, longitude: long, timeZone: timezone))
        } else {
            zmanimCalendar = ComplexZmanimCalendar(location: GeoLocation(locationName: locationName, latitude: lat, longitude: long, elevation: elevation, timeZone: timezone))
        }
        zmanimCalendar.useElevation = GlobalStruct.useElevation
        zmanimCalendar.useAstronomicalChatzos = false
        GlobalStruct.geoLocation = zmanimCalendar.geoLocation
    }
    
    public func syncCalendarDates() {//with userChosenDate
        zmanimCalendar.workingDate = userChosenDate
        jewishCalendar.workingDate = userChosenDate
        GlobalStruct.jewishCalendar.workingDate = userChosenDate
    }
}

struct GlobalStruct {
    static var useElevation = false
    static var geoLocation = GeoLocation()
    static var jewishCalendar = JewishCalendar()
    static var chosenPrayer = ""
}

struct Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes: ActivityAttributes {
    public typealias TimerStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var endTime: Date
    }

    // Fixed non-changing properties about your activity go here!
    var zmanName: String
}
