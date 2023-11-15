//
//  ViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 2/10/23.
//

import UIKit
import KosherCocoa
import CoreLocation
import ActivityKit

class ZmanListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    var allZmanimAreTheSame = true
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func prevDayButton(_ sender: Any) {
        userChosenDate = userChosenDate.advanced(by: -86400)
        syncCalendarDates()
        updateZmanimList()
        checkIfTablesNeedToBeUpdated()
        zmanimTableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
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
        zmanimTableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
    }
    @IBOutlet weak var ShabbatModeBanner: MarqueeLabel!
    @IBOutlet weak var menuButton: UIButton!
    
    func createMenu() {
        var topMenu:[UIAction] = []
        var bottomMenu:[UIAction] = []
        
        topMenu.append(UIAction(title: "Shabbat/Chag Mode", identifier: nil, state: self.shabbatMode ? .on : .off) { _ in
            if self.shabbatMode {
                self.endShabbatMode()
            } else {
                self.startShabbatMode()
            }
            self.createMenu()
        })
        
        topMenu.append(UIAction(title: "Use Elevation", identifier: nil, state: self.defaults.bool(forKey: "useElevation") ? .on : .off) { _ in
            self.defaults.set(!self.defaults.bool(forKey: "useElevation"), forKey: "useElevation")
            GlobalStruct.useElevation = self.defaults.bool(forKey: "useElevation")
            if self.defaults.object(forKey: "elevation" + self.locationName) != nil {//if we have been here before, use the elevation saved for this location
                self.elevation = self.defaults.double(forKey: "elevation" + self.locationName)
            } else {//we have never been here before, get the elevation from online
                if self.defaults.bool(forKey: "useElevation")  && !self.defaults.bool(forKey: "LuachAmudeiHoraah") {
                    self.getElevationFromOnline()
                } else {
                    self.elevation = 0//undo any previous values
                }
            }
            self.createMenu()
            self.recreateZmanimCalendar()
            self.setNextUpcomingZman()
            self.updateZmanimList()
        })
        
        topMenu.append(UIAction(title: "Netz Countdown", identifier: nil) { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "Netz") as! NetzViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true)
        })
        
        topMenu.append(UIAction(title: "Molad Calculator", identifier: nil) { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "Molad") as! MoladViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true)
        })
        
        bottomMenu.append(UIAction(title: "Setup", identifier: nil) { _ in
            self.showSetup()
        })
        
        bottomMenu.append(UIAction(title: "Search For A Place", identifier: nil) { _ in
            self.showZipcodeAlert()
        })
        
        bottomMenu.append(UIAction(title: "Website", identifier: nil) { _ in
            if let url = URL(string: "https://royzmanim.com/") {
                    UIApplication.shared.open(url)
            }
        })
        
        bottomMenu.append(UIAction(title: "Settings", identifier: nil) { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true)
        })
        
        let menu = UIMenu(options: .displayInline, children: [UIMenu(title: "", options: .displayInline, children: topMenu), UIMenu(options: .displayInline, children:[UIMenu(title: "", options: .displayInline, children: bottomMenu)])])
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
                            roundedFormat.dateFormat = "h:mm aa"
                            content.text = roundedFormat.string(from: zman!) + arrow
                        } else if zmanimList[indexPath.row].isVisibleSunriseZman {
                            let secondsFormat = DateFormatter()
                            secondsFormat.dateFormat = "h:mm:ss aa"
                            content.text = secondsFormat.string(from: zman!) + arrow
                        } else {
                            content.text = dateFormatterForZmanim.string(from: zman!) + arrow
                        }
                    } else {
                        if zmanimList[indexPath.row].isRTZman && defaults.bool(forKey: "roundUpRT") {
                            zman = zman?.advanced(by: 60)
                            let roundedFormat = DateFormatter()
                            roundedFormat.timeZone = timezone
                            roundedFormat.dateFormat = "h:mm aa"
                            content.text = roundedFormat.string(from: zman!)
                        } else if zmanimList[indexPath.row].isVisibleSunriseZman {
                            let secondsFormat = DateFormatter()
                            secondsFormat.dateFormat = "h:mm:ss aa"
                            content.text = secondsFormat.string(from: zman!)
                        }  else {
                            content.text = dateFormatterForZmanim.string(from: zman!)
                        }
                    }
                }
                if allZmanimAreTheSame {
                    content.text = "..."
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
                if allZmanimAreTheSame {
                    content.secondaryText = "..."
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
        
        var alertController = UIAlertController(title: zmanimInfo.getFullTitle(), message: zmanimInfo.getFullMessage(), preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: zmanimInfo.getFullTitle(), message: zmanimInfo.getFullMessage(), preferredStyle: .alert)
        }
        
        if indexPath.row == 0 {
            var message = ""
            message += "Current Location: " + self.locationName
            message += "\nCurrent Latitude: " + String(self.lat)
            message += "\nCurrent Longitude: " + String(self.long)
            message += "\nElevation: " + String(self.elevation) + " meters"
            message += "\nCurrent Time Zone: " + self.timezone.identifier
            
            alertController.title = "Location info for: " + self.locationName
            alertController.message = message
            let locationAction = UIAlertAction(title: "Change Location", style: .default) { [self] (_) in
                self.showZipcodeAlert()
            }
            alertController.addAction(locationAction)
            if !defaults.bool(forKey: "LuachAmudeiHoraah") {
                let elevationAction = UIAlertAction(title: "Set Elevation", style: .default) { [self] (_) in
                    self.setupElevetion((Any).self)
                }
                alertController.addAction(elevationAction)
            }
        }
        
        if zmanimList[indexPath.row].title.contains(ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getHaNetzString()) {
            let setupSunriseAction = UIAlertAction(title: "Setup Visible Sunrise", style: .default) { [self] (_) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyboard.instantiateViewController(withIdentifier: "SetupChooser") as! SetupChooserViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true)
            }
            alertController.addAction(setupSunriseAction)
        }
        
        if zmanimList[indexPath.row].title == "Daily Siddur" {
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
                let activityAction = UIAlertAction(title: "Keep track of this zman with a Live Activity?", style: .default) {_ in 
                    let attributes = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes(zmanName: self.zmanimList[indexPath.row].title)
                    let contentState = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes.TimerStatus(endTime: self.zmanimList[indexPath.row].zman ?? Date())
                    _ = try? Activity<Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes>.request(attributes: attributes, content: ActivityContent.init(state: contentState, staleDate: nil), pushType: nil)
                }
                alertController.addAction(activityAction)
            }
        }

        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in }
        alertController.addAction(dismissAction)

        if !zmanimInfo.getFullMessage().isEmpty || indexPath.row == 0 {
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func refreshTable() {
        if defaults.bool(forKey: "useZipcode") {
            locationName = defaults.string(forKey: "locationName") ?? ""
            lat = defaults.double(forKey: "lat")
            long = defaults.double(forKey: "long")
            elevation = defaults.double(forKey: "elevation" + locationName)
            timezone = TimeZone.init(identifier: defaults.string(forKey: "timezone")!)!
            recreateZmanimCalendar()
        } else {
            getUserLocation()
        }
        userChosenDate = Date()
        syncCalendarDates()
        updateZmanimList()
        zmanimTableView.refreshControl?.endRefreshing()
    }
    
    @objc func showDatePicker() {
        var alertController = UIAlertController(title: "Select a date", message: nil, preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Select a date", message: nil, preferredStyle: .alert)
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
        
        let changeCalendarAction = UIAlertAction(title: "Switch Calendar", style: .default) { (_) in
            self.dismiss(animated: true)
            self.showHebrewDatePicker()
        }

        alertController.addAction(changeCalendarAction)

        let doneAction = UIAlertAction(title: "Done", style: .default) { (_) in
            self.syncCalendarDates()
            self.updateZmanimList()
            self.checkIfTablesNeedToBeUpdated()
            self.zmanimTableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
        }

        alertController.addAction(doneAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showHebrewDatePicker() {
        var alertController = UIAlertController(title: "Select a date", message: nil, preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Select a date", message: nil, preferredStyle: .alert)
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
        
        let changeCalendarAction = UIAlertAction(title: "Switch Calendar", style: .default) { (_) in
            self.dismiss(animated: true)
            self.showDatePicker()
        }

        alertController.addAction(changeCalendarAction)

        let doneAction = UIAlertAction(title: "Done", style: .default) { (_) in
            self.syncCalendarDates()
            self.updateZmanimList()
            self.checkIfTablesNeedToBeUpdated()
            self.zmanimTableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
        }

        alertController.addAction(doneAction)

        present(alertController, animated: true, completion: nil)
    }

    // Function to handle changes to the date picker value
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        userChosenDate = sender.date
    }
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {//this method happens 2nd
        super.viewWillAppear(animated)
        if defaults.bool(forKey: "showSeconds") {
            dateFormatterForZmanim.dateFormat = "h:mm:ss aa"
        } else {
            dateFormatterForZmanim.dateFormat = "h:mm aa"
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
        } else {//not first run
            if defaults.bool(forKey: "useZipcode") {
                locationName = defaults.string(forKey: "locationName") ?? ""
                lat = defaults.double(forKey: "lat")
                long = defaults.double(forKey: "long")
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
                timezone = TimeZone.init(identifier: defaults.string(forKey: "timezone")!)!
                recreateZmanimCalendar()
                jewishCalendar = JewishCalendar(location: zmanimCalendar.geoLocation)
                jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
                jewishCalendar.returnsModernHolidays = true
                setNextUpcomingZman()
                updateZmanimList()
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
        lastTimeUserWasInApp = Date()
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
            let alertController = UIAlertController(title: "Are you in Israel now?", message: "If you are in Israel, please confirm below.", preferredStyle: .alert)

            let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                self.defaults.set(true, forKey: "inIsrael")
                self.defaults.set(false, forKey: "LuachAmudeiHoraah")
                self.jewishCalendar.inIsrael = true
                self.updateZmanimList()
            }

            alertController.addAction(yesAction)
            
            let noAction = UIAlertAction(title: "No", style: .default) { (_) in
                self.defaults.set(false, forKey: "inIsrael")
                self.jewishCalendar.inIsrael = false
                self.updateZmanimList()
            }

            alertController.addAction(noAction)
            
            let noAskAction = UIAlertAction(title: "Do Not Ask Again", style: .default) { (_) in
                self.defaults.set(true, forKey: "neverAskInIsrael")
            }

            alertController.addAction(noAskAction)

            present(alertController, animated: true, completion: nil)
        }
        
        if defaults.bool(forKey: "inIsrael") && timezone.identifier != "Asia/Jerusalem" {
            let alertController = UIAlertController(title: "Have you left Israel?", message: "If you have left  Israel, please confirm below.", preferredStyle: .alert)

            let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                self.defaults.set(false, forKey: "inIsrael")
                self.jewishCalendar.inIsrael = false
                self.updateZmanimList()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyboard.instantiateViewController(withIdentifier: "SetupChooser") as! CalendarViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true)
            }

            alertController.addAction(yesAction)
            
            let noAction = UIAlertAction(title: "No", style: .default) { (_) in
                self.defaults.set(true, forKey: "inIsrael")
                self.jewishCalendar.inIsrael = true
                self.updateZmanimList()
            }

            alertController.addAction(noAction)
            
            let noAskAction = UIAlertAction(title: "Do Not Ask Again", style: .default) { (_) in
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
        let chaitables = ChaiTables(locationName: locationName, jewishYear: jewishCalendar.currentHebrewYear(), defaults: defaults)
        if chaitables.getVisibleSurise(forDate: userChosenDate) == nil {
            let alert = UIAlertController(title: "Chaitables out of date", message: "The current hebrew year is out of scope for the visible sunrise times that were downloaded from Chaitables. Would you like to download the tables for this hebrew year?", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { [weak alert] (_) in
                let oldLink = self.defaults.string(forKey: "chaitablesLink" + self.locationName)
                let hebrewYear = String(self.jewishCalendar.currentHebrewYear())
                let pattern = "&cgi_yrheb=\\d{4}"
                let newLink = oldLink?.replacingOccurrences(of: pattern, with: "&cgi_yrheb=" + hebrewYear, options: .regularExpression)
                let scraper = ChaiTablesScraper(link: newLink ?? "", locationName: self.locationName, jewishYear: self.jewishCalendar.currentHebrewYear(), defaults: self.defaults)
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
            self.jewishCalendar = JewishCalendar(location: self.zmanimCalendar.geoLocation)
            self.jewishCalendar.inIsrael = self.defaults.bool(forKey: "inIsrael")
            self.jewishCalendar.returnsModernHolidays = true
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
            jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
        }
        
        let isShabbat = jewishCalendar.currentDayOfTheWeek() == 7
        
        var bannerText = ""
        
        switch jewishCalendar.yomTovIndex() {
        case Int(kPesach.rawValue):
            for _ in 0...4 {
                bannerText += "PESACH"
                if isShabbat {
                    bannerText += "/SHABBAT"
                }
                bannerText += "MODE          "
            }
            ShabbatModeBanner.backgroundColor = .init(named:"light_yellow")
            ShabbatModeBanner.textColor = .black
        case Int(kShavuos.rawValue):
            for _ in 0...4 {
                bannerText += "SHAVUOT"
                if isShabbat {
                    bannerText += "/SHABBAT"
                }
                bannerText += "MODE          "
            }
            ShabbatModeBanner.backgroundColor = .systemBlue
            ShabbatModeBanner.textColor = .white
        case Int(kSuccos.rawValue):
            for _ in 0...4 {
                bannerText += "SUCCOT"
                if isShabbat {
                    bannerText += "/SHABBAT"
                }
                bannerText += "MODE          "
            }
            ShabbatModeBanner.backgroundColor = .systemGreen
            ShabbatModeBanner.textColor = .black
        case Int(kSheminiAtzeres.rawValue):
            for _ in 0...4 {
                bannerText += "SHEMINI ATZERET"
                if isShabbat {
                    bannerText += "/SHABBAT"
                }
                bannerText += "MODE          "
            }
            ShabbatModeBanner.backgroundColor = .systemGreen
            ShabbatModeBanner.textColor = .black
        case Int(kSimchasTorah.rawValue):
            for _ in 0...4 {
                bannerText += "SIMCHAT TORAH"
                if isShabbat {
                    bannerText += "/SHABBAT"
                }
                bannerText += "MODE          "
            }
            ShabbatModeBanner.backgroundColor = .green
            ShabbatModeBanner.textColor = .black
        case Int(kRoshHashana.rawValue):
            for _ in 0...4 {
                bannerText += "ROSH HASHANA"
                if isShabbat {
                    bannerText += "/SHABBAT"
                }
                bannerText += "MODE          "
            }
            ShabbatModeBanner.backgroundColor = .red
            ShabbatModeBanner.textColor = .white
        case Int(kYomKippur.rawValue):
            for _ in 0...4 {
                bannerText += "YOM KIPPUR"
                if isShabbat {
                    bannerText += "/SHABBAT"
                }
                bannerText += "MODE          "
            }
            ShabbatModeBanner.backgroundColor = .white
            ShabbatModeBanner.textColor = .black
        default:
            bannerText = "Shabbat Mode          Shabbat Mode          Shabbat Mode           Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          Shabbat Mode          "
            ShabbatModeBanner.backgroundColor = .init(named:"dark_blue")
            ShabbatModeBanner.textColor = .white
        }
        
        ShabbatModeBanner.text = bannerText
        
        if isFirstTime {
            jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: -86400)
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
            && jewishCalendar.yomTovIndex() != kTishaBeav.rawValue
            && jewishCalendar.yomTovIndex() != kYomKippur.rawValue {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.alos72Zmanis(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.alos72Zmanis(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.talitTefilin(), isZman: true))
        let chaitables = ChaiTables(locationName: locationName, jewishYear: jewishCalendar.currentHebrewYear(), defaults: defaults)
        let visibleSurise = chaitables.getVisibleSurise(forDate: userChosenDate)
        if visibleSurise != nil {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true, isVisibleSunriseZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
        }
        if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.sofZmanShmaMGA72MinutesZmanis(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.sofZmanShmaGra(), isZman: true))
        if jewishCalendar.yomTovIndex() == kErevPesach.rawValue {
            temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman:zmanimCalendar.sofZmanTfilaMGA72MinutesZmanis(), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman:zmanimCalendar.sofZmanBiurChametzMGA(), isZman: true, isNoteworthyZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman:zmanimCalendar.chatzos(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman:zmanimCalendar.minchaGedolaGreaterThan30(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman:zmanimCalendar.minchaKetana(), isZman: true))
        if defaults.integer(forKey: "plagOpinion") == 1 || defaults.object(forKey: "plagOpinion") == nil {
            temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString(), zman:zmanimCalendar.plagHamincha(), isZman: true))
        } else if defaults.integer(forKey: "plagOpinion") == 2 {
            temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.plagHaminchaHalachaBerurah(), isZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.plagHaminchaHalachaBerurah(), isZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedYalkutYosefString(), zman:zmanimCalendar.plagHamincha(), isZman: true))
        }
        if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.currentDayOfTheWeek() == 6 {
            zmanimCalendar.candleLightingOffset = 20
            if defaults.object(forKey: "candleLightingOffset") != nil {
                zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
            }
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman:zmanimCalendar.candleLighting(), isZman: true, isNoteworthyZman: true))
        }
        if defaults.bool(forKey: "showWhenShabbatChagEnds") {
            if jewishCalendar.currentDayOfTheWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni() {
                jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go to the next day
                if !(jewishCalendar.currentDayOfTheWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni()) {//only add if shabbat/chag actually ends
                    if defaults.bool(forKey: "showRegularWhenShabbatChagEnds") {
                        zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
                        if defaults.object(forKey: "shabbatOffset") != nil {
                            zmanimCalendar.ateretTorahSunsetOffset = Int32(defaults.integer(forKey: "shabbatOffset"))
                        }
                        if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + " (" + String(zmanimCalendar.ateretTorahSunsetOffset) + ")", zman:zmanimCalendar.tzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
                        } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
                        } else {
                            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
                        }
                    }
                    if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                        temp.append(ZmanListEntry(title: zmanimNames.getRTString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzais72Zmanis(), isZman: true))
                    }
                }
                jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: -86400)
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
            }
        }
        jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
        if jewishCalendar.yomTovIndex() == kTishaBeav.rawValue {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman:zmanimCalendar.sunset(), isZman: true))
        }
        jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: -86400)
        temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.sunset(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.tzeit(), isZman: true))
        if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.currentDayOfTheWeek() != 6 {
            if jewishCalendar.currentDayOfTheWeek() == 7 {
                zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
                if defaults.object(forKey: "shabbatOffset") != nil {
                    zmanimCalendar.ateretTorahSunsetOffset = Int32(defaults.integer(forKey: "shabbatOffset"))
                }
                if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                    temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
                } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                    temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
                } else {
                    temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
                }
            } else {// just yom tov
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzeit(), isZman: true, isNoteworthyZman: true))
            }
        }
        if jewishCalendar.isTaanis() && jewishCalendar.yomTovIndex() != kYomKippur.rawValue {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzeitTaanit(), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.tzeitTaanitLChumra(), isZman: true, isNoteworthyZman: true))
        } else if defaults.bool(forKey: "showTzeitLChumra") {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman: zmanimCalendar.tzeitTaanit(), isZman: true))
        }
        if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
            zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
            if defaults.object(forKey: "shabbatOffset") != nil {
                zmanimCalendar.ateretTorahSunsetOffset = Int32(defaults.integer(forKey: "shabbatOffset"))
            }
            if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + " (" + String(zmanimCalendar.ateretTorahSunsetOffset) + ")", zman:zmanimCalendar.tzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
            } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            } else {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
            }
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72Zmanit(), isZman: true, isNoteworthyZman: true, isRTZman: true))
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
                temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72Zmanit(), isZman: true, isNoteworthyZman: true, isRTZman: true))
            }
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.solarMidnight(), isZman: true))
        return temp
    }
    
    func addAmudeiHoraahZmanim(list:Array<ZmanListEntry>) -> Array<ZmanListEntry> {
        var temp = list
        let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        if jewishCalendar.isTaanis()
            && jewishCalendar.yomTovIndex() != kTishaBeav.rawValue
            && jewishCalendar.yomTovIndex() != kYomKippur.rawValue {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.alotAmudeiHoraah(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.alotAmudeiHoraah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.talitTefilinAmudeiHoraah(), isZman: true))
        let chaitables = ChaiTables(locationName: locationName, jewishYear: jewishCalendar.currentHebrewYear(), defaults: defaults)
        let visibleSurise = chaitables.getVisibleSurise(forDate: userChosenDate)
        if visibleSurise != nil {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true, isVisibleSunriseZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
        }
        if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.shmaMGAAmudeiHoraah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.sofZmanShmaGra(), isZman: true))
        if jewishCalendar.yomTovIndex() == kErevPesach.rawValue {
            temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman:zmanimCalendar.achilatChametzAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman:zmanimCalendar.biurChametzAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman:zmanimCalendar.chatzos(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman:zmanimCalendar.minchaGedolaGreaterThan30(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman: zmanimCalendar.minchaKetana(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.plagHaminchaHalachaBerurah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedYalkutYosefString(), zman:zmanimCalendar.plagHaminchaYalkutYosefAmudeiHoraah(), isZman: true))
        if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.currentDayOfTheWeek() == 6 {
            zmanimCalendar.candleLightingOffset = 20
            if defaults.object(forKey: "candleLightingOffset") != nil {
                zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
            }
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman:zmanimCalendar.candleLighting(), isZman: true, isNoteworthyZman: true))
        }
        if defaults.bool(forKey: "showWhenShabbatChagEnds") {
            if jewishCalendar.currentDayOfTheWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni() {
                jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go to the next day
                if !(jewishCalendar.currentDayOfTheWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni()) {//only add if shabbat/chag actually ends
                    if defaults.bool(forKey: "showRegularWhenShabbatChagEnds") {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true))
                    }
                    if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                        temp.append(ZmanListEntry(title: zmanimNames.getRTString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzait72ZmanitAmudeiHoraahLkulah(), isZman: true))
                    }
                }
                jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: -86400)
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
            }
        }
        jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
        if jewishCalendar.yomTovIndex() == kTishaBeav.rawValue {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman:zmanimCalendar.sunset(), isZman: true))
        }
        jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: -86400)
        temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.seaLevelSunset(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.tzaitAmudeiHoraah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.tzaitAmudeiHoraahLChumra(), isZman: true))
        if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.currentDayOfTheWeek() != 6 {
            if jewishCalendar.currentDayOfTheWeek() == 7 {
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            } else {// just yom tov
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaitAmudeiHoraahLChumra(), isZman: true, isNoteworthyZman: true))
            }
        }
        if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72ZmanitAmudeiHoraahLkulah(), isZman: true, isNoteworthyZman: true, isRTZman: true))
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
                temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72ZmanitAmudeiHoraahLkulah(), isZman: true, isNoteworthyZman: true, isRTZman: true))
            }
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.solarMidnight(), isZman: true))
        return temp
    }
    
    func getUserLocation() {
        LocationManager.shared.getUserLocation {
            location in DispatchQueue.main.async { [self] in
                self.lat = location.coordinate.latitude
                self.long = location.coordinate.longitude
                self.timezone = TimeZone.current
                self.recreateZmanimCalendar()
                self.defaults.set(timezone.identifier, forKey: "timezone")
                self.defaults.set(true, forKey: "isSetup")
                self.defaults.set(false, forKey: "useZipcode")
                LocationManager.shared.resolveLocationName(with: location) { [self] locationName in
                    self.locationName = locationName ?? ""
                    if self.defaults.object(forKey: "elevation" + self.locationName) != nil {//if we have been here before, use the elevation saved for this location
                        self.elevation = self.defaults.double(forKey: "elevation" + self.locationName)
                    } else {//we have never been here before, get the elevation from online
                        if self.defaults.bool(forKey: "useElevation") && !self.defaults.bool(forKey: "LuachAmudeiHoraah") {
                            self.getElevationFromOnline()
                        } else {
                            self.elevation = 0//undo any previous values
                        }
                    }
                    if self.locationName.isEmpty {
                        self.locationName = "Lat: " + String(lat) + " Long: " + String(long)
                        if defaults.bool(forKey: "setElevationToLastKnownLocation") {
                            self.elevation = self.defaults.double(forKey: "elevation" + (defaults.string(forKey: "lastKnownLocation") ?? ""))
                        }
                    }
                    self.recreateZmanimCalendar()
                    jewishCalendar = JewishCalendar(location: zmanimCalendar.geoLocation)
                    jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
                    jewishCalendar.returnsModernHolidays = true
                    setNextUpcomingZman()
                    updateZmanimList()
                    NotificationManager.instance.requestAuthorization()
                    NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
                }
            }
        }
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
                
        let hebrewDateFormatter = DateFormatter()
        hebrewDateFormatter.calendar = Calendar(identifier: .hebrew)
        hebrewDateFormatter.dateFormat = "d MMMM, yyyy"
        let hebrewDate = hebrewDateFormatter.string(from: userChosenDate)
            .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
            .replacingOccurrences(of: "Tamuz", with: "Tammuz")
        
        if Calendar.current.isDateInToday(userChosenDate) {
            date += "   ▼   " + hebrewDate
        } else {
            date += "       " + hebrewDate
        }
        zmanimList.append(ZmanListEntry(title:date))
        //forward jewish calendar to saturday
        while jewishCalendar.currentDayOfTheWeek() != 7 {
            jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
        }
        //now that we are on saturday, check the parasha
        let specialParasha = jewishCalendar.getSpecialParasha()
        var parasha = ""
        
        if defaults.bool(forKey: "inIsrael") {
            parasha = ParashatHashavuaCalculator().parashaInIsrael(for: jewishCalendar.workingDate).name()
        } else {
            parasha = ParashatHashavuaCalculator().parashaInDiaspora(for: jewishCalendar.workingDate).name()
        }
        if !specialParasha.isEmpty {
            parasha += " / " + specialParasha
        }
        zmanimList.append(ZmanListEntry(title:parasha))
        syncCalendarDates()//reset
        dateFormatter.dateFormat = "EEEE"
        zmanimList.append(ZmanListEntry(title:dateFormatter.string(from: zmanimCalendar.workingDate) + " / " + getHebrewDay(day: jewishCalendar.currentDayOfTheWeek())))
        let specialDay = jewishCalendar.getSpecialDay(addOmer:true)
        if !specialDay.isEmpty {
            zmanimList.append(ZmanListEntry(title:specialDay))
        }
        if jewishCalendar.is3Weeks() {
            if jewishCalendar.is9Days() {
                if jewishCalendar.isShevuahShechalBo() {
                    zmanimList.append(ZmanListEntry(title: "Shevuah Shechal Bo"))
                } else {
                    zmanimList.append(ZmanListEntry(title: "Nine Days"))
                }
            } else {
                zmanimList.append(ZmanListEntry(title: "Three Weeks"))
            }
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
            zmanimList.append(ZmanListEntry(title: "Birchat HaChamah is said today"))
        }
        dateFormatter.dateFormat = "h:mm aa"
        dateFormatter.timeZone = timezone
        let tekufaSetting = defaults.integer(forKey: "tekufaOpinion")
        if tekufaSetting == 1 {
            let tekufa = jewishCalendar.getTekufaAsDate()
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufa!)))
                }
            }
            jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: checkTomorrowForTekufa!)))
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        } else if tekufaSetting == 2 {
            let tekufa = jewishCalendar.getAmudeiHoraahTekufaAsDate()
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufa!)))
                }
            }
            jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
            let checkTomorrowForTekufa = jewishCalendar.getAmudeiHoraahTekufaAsDate()
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: checkTomorrowForTekufa!)))
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        } else {
            let tekufa = jewishCalendar.getTekufaAsDate()
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufa!)))
                }
            }
            jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: checkTomorrowForTekufa!)))
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
            
            let tekufaAH = jewishCalendar.getAmudeiHoraahTekufaAsDate()
            if tekufaAH != nil {
                if Calendar.current.isDate(tekufaAH!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufaAH!)))
                }
            }
            jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
            let checkTomorrowForAHTekufa = jewishCalendar.getAmudeiHoraahTekufaAsDate()
            if checkTomorrowForAHTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForAHTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: checkTomorrowForAHTekufa!)))
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        }
        
        zmanimList = addZmanim(list: zmanimList)
        
        let dafYomi = jewishCalendar.dafYomiBavli()
        if dafYomi != nil {
            zmanimList.append(ZmanListEntry(title:"Daf Yomi: " + ((dafYomi!.name())) + " " + dafYomi!.pageNumber.formatHebrew()))
        }
        let dateString = "1980-02-02"//Yerushalmi start date
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let yerushalmiYomi = DafYomiCalculator(date: userChosenDate).dafYomiYerushalmi(calendar: jewishCalendar)
        if let targetDate = dateFormatter.date(from: dateString) {
            let comparisonResult = targetDate.compare(userChosenDate)
            if comparisonResult == .orderedDescending {
                print("The target date is before Feb 2, 1980.")
            } else if comparisonResult == .orderedAscending {
                if yerushalmiYomi != nil {
                    zmanimList.append(ZmanListEntry(title:"Yerushalmi Vilna Yomi: " +  yerushalmiYomi!.nameYerushalmi() + " " + yerushalmiYomi!.pageNumber.formatHebrew()))
                } else {
                    zmanimList.append(ZmanListEntry(title:"No Yerushalmi Vilna Yomi"))
                }
            }
        }
        zmanimList.append(ZmanListEntry(title:jewishCalendar.getIsMashivHaruchOrMoridHatalSaid() + " / " + jewishCalendar.getIsBarcheinuOrBarechAleinuSaid()))
        if !shabbatMode {
            zmanimList.append(ZmanListEntry(title: "Daily Siddur"))
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        if defaults.bool(forKey: "LuachAmudeiHoraah") {
            zmanimList.append(ZmanListEntry(title:"GRA: " + (formatter.string(from: TimeInterval(zmanimCalendar.shaahZmanisGra())) ?? "XX:XX") + " / " + "MGA: " + (formatter.string(from: TimeInterval(zmanimCalendar.temporalHour(fromSunrise: zmanimCalendar.alotAmudeiHoraah() ?? Date(), toSunset: zmanimCalendar.tzait72ZmanitAmudeiHoraah() ?? Date()))) ?? "XX:XX")))
        } else {
            zmanimList.append(ZmanListEntry(title:"GRA: " + (formatter.string(from: TimeInterval(zmanimCalendar.shaahZmanisGra())) ?? "XX:XX") + " / " + "MGA: " + (formatter.string(from: TimeInterval(zmanimCalendar.shaahZmanis72MinutesZmanis())) ?? "XX:XX")))
        }
        if zmanimCalendar.sunrise()?.timeIntervalSince1970 != zmanimCalendar.sunset()?.timeIntervalSince1970 {
            allZmanimAreTheSame = false
        }
        zmanimTableView.reloadData()
    }
    
    func getShabbatAndOrChag() -> String {
        if (defaults.bool(forKey: "isZmanimInHebrew")) {
            if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.currentDayOfTheWeek() == 7 {
                return "\u{05E9}\u{05D1}\u{05EA}/\u{05D7}\u{05D2}"
            } else if jewishCalendar.currentDayOfTheWeek() == 7 {
                return "\u{05E9}\u{05D1}\u{05EA}"
            } else {
                return "\u{05D7}\u{05D2}"
            }
        } else {
            if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.currentDayOfTheWeek() == 7 {
                return "Shabbat/Chag";
            } else if jewishCalendar.currentDayOfTheWeek() == 7 {
                return "Shabbat";
            } else {
                return "Chag";
            }
        }
    }
    
    func showZipcodeAlert() {
        let alert = UIAlertController(title: "Location or Search a place?",
                                      message: "You can choose to use your device's location, or you can search for a place below. It is recommended to use your devices location as this provides more accurate results and it will automatically update your location.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Zipcode/Address"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            //if text is empty, display a message notifying the user:
            if textField?.text == "" {
                let alert = UIAlertController(title: "Error", message: "Please enter a valid zipcode or address.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                    self.showZipcodeAlert()
                }))
                self.present(alert, animated: true)
                return
            }
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString((textField?.text)!, completionHandler: { i, j in
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
                    name = "No location name info"
                }
                self.locationName = name
                let coordinates = i?.first?.location?.coordinate
                self.lat = coordinates?.latitude ?? 0
                self.long = coordinates?.longitude ?? 0
                if self.defaults.object(forKey: "elevation" + self.locationName) != nil {//if we have been here before, use the elevation saved for this location
                    self.elevation = self.defaults.double(forKey: "elevation" + self.locationName)
                } else {//we have never been here before, get the elevation from online
                    if self.defaults.bool(forKey: "useElevation") {
                        self.getElevationFromOnline()
                    }
                    self.elevation = 0//undo any previous values
                }
                if i?.first?.timeZone != nil {
                    self.timezone = (i?.first?.timeZone)!
                }
                self.recreateZmanimCalendar()
                self.defaults.set(name, forKey: "locationName")
                self.defaults.set(self.lat, forKey: "lat")
                self.defaults.set(self.long, forKey: "long")
                self.defaults.set(true, forKey: "isSetup")
                self.defaults.set(true, forKey: "useZipcode")
                self.defaults.set(self.timezone.identifier, forKey: "timezone")
                NotificationManager.instance.requestAuthorization()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { UIAlertAction in
            alert.dismiss(animated: true) {}
        }))
        alert.addAction(UIAlertAction(title: "Use Location", style: .default, handler: { UIAlertAction in
            self.getUserLocation()
            self.defaults.set(true, forKey: "isSetup")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didGetNotification(_ notification: Notification) {
        if notification.object != nil {
            let amount = notification.object as! String
            elevation = NumberFormatter().number(from: amount)!.doubleValue
            defaults.set(elevation, forKey: "elevation" + locationName)
        }
        recreateZmanimCalendar()
    }
    
    public func recreateZmanimCalendar() {
        if defaults.bool(forKey: "LuachAmudeiHoraah") {
            zmanimCalendar = ComplexZmanimCalendar(location: GeoLocation(name: locationName, andLatitude: lat, andLongitude: long, andTimeZone: timezone))
        } else {
            zmanimCalendar = ComplexZmanimCalendar(location: GeoLocation(name: locationName, andLatitude: lat, andLongitude: long, andElevation: elevation, andTimeZone: timezone))
        }
        GlobalStruct.geoLocation = zmanimCalendar.geoLocation
    }
    
    public func getHebrewDay(day:Int) -> String {
        var dayHebrew = "יום "
        if day == 1 {
            dayHebrew += "ראשון"
        }
        if day == 2 {
            dayHebrew += "שני"
        }
        if day == 3 {
            dayHebrew += "שלישי"
        }
        if day == 4 {
            dayHebrew += "רביעי"
        }
        if day == 5 {
            dayHebrew += "חמישי"
        }
        if day == 6 {
            dayHebrew += "ששי"
        }
        if day == 7 {
            dayHebrew += "שבת"
        }
        return dayHebrew
    }
    
    public func syncCalendarDates() {//with userChosenDate
        zmanimCalendar.workingDate = userChosenDate
        jewishCalendar.workingDate = userChosenDate
    }
}

struct GlobalStruct {
    static var useElevation = false
    static var geoLocation = GeoLocation()
    static var jewishCalendar = JewishCalendar()
    static var chosenPrayer = ""
}

public extension ComplexZmanimCalendar {
    
    func tzait72Zmanit() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        return sunset()?.addingTimeInterval(shaahZmanit*1.2);
    }
    
    func tzeitTaanitLChumra() -> Date? {
        return sunset()?.addingTimeInterval(30 * 60);
    }
    
    func tzeitTaanit() -> Date? {
        return sunset()?.addingTimeInterval(20 * 60);
    }
    
    func tzeit() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        
        return sunset()?.addingTimeInterval(13 * dakahZmanit + (dakahZmanit / 2));
    }
    
    override func sunset() -> Date? {
        if GlobalStruct.useElevation {
            return super.sunset()
        }
        return super.seaLevelSunset()
    }
    
    override func sunrise() -> Date? {
        if GlobalStruct.useElevation {
            return super.sunrise()
        }
        return super.seaLevelSunrise()
    }
    
    func seaLevelSunriseOnly() -> Date? {
        return super.seaLevelSunrise()
    }
    
    override func plagHamincha() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        
        return tzeit()?.addingTimeInterval(-(shaahZmanit + (15 * dakahZmanit)));
    }
    
    func sofZmanBiurChametzMGA() -> Date? {
        let shaahZmanit = shaahZmanitMga()
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        return alos72Zmanis()?.addingTimeInterval(5 * shaahZmanit)
    }
    
    func talitTefilin() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        
        return alos72Zmanis()?.addingTimeInterval(6 * dakahZmanit);
    }
    
    override func shaahZmanisGra() -> Double {
        var sunrise = seaLevelSunrise()
        var sunset = seaLevelSunset()
        if GlobalStruct.useElevation {
            sunrise = self.sunrise()
            sunset = self.sunset()
        }
        if sunrise == nil || sunset == nil {
            return .leastNormalMagnitude
        }
        return temporalHour(fromSunrise: sunrise!, toSunset: sunset!)
    }
    
    func shaahZmanitMga() -> Double {
        let alot = alos72Zmanis()
        let tzait = tzait72Zmanit()
        if alot == nil || tzait == nil {
            return .leastNormalMagnitude
        }
        return temporalHour(fromSunrise: alos72Zmanis()!, toSunset: tzait72Zmanit()!)
    }
    
    //Amudei Horaah zmanim start here
    
    func plagHaminchaYalkutYosefAmudeiHoraah() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        
        return tzaitAmudeiHoraah()?.addingTimeInterval(-(shaahZmanit + (15 * dakahZmanit)));
    }
    
    func plagHaminchaHalachaBerurah() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        
        return sunset()?.addingTimeInterval(-(shaahZmanit + (15 * dakahZmanit)));
    }
    
    func alotAmudeiHoraah() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let alotBy16Degrees = sunriseOffset(byDegrees:90 + 16.04)
        let numberOfSeconds = ((seaLevelSunrise()!.timeIntervalSince1970 - alotBy16Degrees!.timeIntervalSince1970))
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunrise()?.addingTimeInterval(-(numberOfSeconds * secondsZmanit));
    }
    
    func talitTefilinAmudeiHoraah() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let alotBy16Degrees = sunriseOffset(byDegrees:90 + 16.04)
        let numberOfSeconds = ((seaLevelSunrise()!.timeIntervalSince1970 - alotBy16Degrees!.timeIntervalSince1970))
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunrise()?.addingTimeInterval(-(numberOfSeconds * secondsZmanit * 5 / 6));
    }
    
    func shmaMGAAmudeiHoraah() -> Date? {
        let shaahZmanit = temporalHour(fromSunrise: alotAmudeiHoraah()!, toSunset: tzait72ZmanitAmudeiHoraah()!)
        return alotAmudeiHoraah()?.addingTimeInterval(3 * shaahZmanit)
    }
    
    func achilatChametzAmudeiHoraah() -> Date? {
        let shaahZmanit = temporalHour(fromSunrise: alotAmudeiHoraah()!, toSunset: tzait72ZmanitAmudeiHoraah()!)
        return alotAmudeiHoraah()?.addingTimeInterval(4 * shaahZmanit)
    }
    
    func biurChametzAmudeiHoraah() -> Date? {
        let shaahZmanit = temporalHour(fromSunrise: alotAmudeiHoraah()!, toSunset: tzait72ZmanitAmudeiHoraah()!)
        return alotAmudeiHoraah()?.addingTimeInterval(5 * shaahZmanit)
    }
    
    func tzaitAmudeiHoraah() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let tzaitGeonimInDegrees = sunsetOffset(byDegrees:90 + 3.77)
        let numberOfSeconds = (tzaitGeonimInDegrees!.timeIntervalSince1970 - seaLevelSunset()!.timeIntervalSince1970)
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunset()?.addingTimeInterval(numberOfSeconds * secondsZmanit);
    }
    
    func tzaitAmudeiHoraahLChumra() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let tzaitGeonimInDegrees = sunsetOffset(byDegrees:90 + 5.135)
        let numberOfSeconds = (tzaitGeonimInDegrees!.timeIntervalSince1970 - seaLevelSunset()!.timeIntervalSince1970)
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunset()?.addingTimeInterval(numberOfSeconds * secondsZmanit);
    }
    
    func tzait72ZmanitAmudeiHoraah() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let tzaitRTInDegrees = sunsetOffset(byDegrees:90 + 16.01)
        let numberOfSeconds = (tzaitRTInDegrees!.timeIntervalSince1970 - seaLevelSunset()!.timeIntervalSince1970)
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunset()?.addingTimeInterval(numberOfSeconds * secondsZmanit);
    }
    
    func tzaitShabbatAmudeiHoraah() -> Date? {
        return sunsetOffset(byDegrees: 90 + 7.14)
    }
    
    func tzaitShabbatAmudeiHoraahLesserThan40() -> Date? {
        if tzaitShabbatAmudeiHoraah()?.compare(tzaisAteretTorah()!) == .orderedDescending {
            return tzaisAteretTorah()
        } else {
            return tzaitShabbatAmudeiHoraah()
        }
    }
    
    func tzait72ZmanitAmudeiHoraahLkulah() -> Date? {
        if tzais72()?.compare(tzait72ZmanitAmudeiHoraah()!) == .orderedDescending {
            return tzait72ZmanitAmudeiHoraah()
        } else {
            return tzais72()
        }
    }
    
}

public extension JewishCalendar {
    
    func getSpecialDay(addOmer: Bool) -> String {
        var result = Array<String>()
        
        let index = yomTovIndex()
        let indexNextDay = getYomTovIndexForNextDay()
        
        let yomTovOfToday = yomTovAsString(index:index)
        let yomTovOfNextDay = yomTovAsString(index:indexNextDay)
        
        if yomTovOfToday.isEmpty && yomTovOfNextDay.isEmpty {
            //Do nothing
        } else if yomTovOfToday.isEmpty && !yomTovOfNextDay.hasPrefix("Erev") {
            result.append("Erev " + yomTovOfNextDay)
        } else if !(yomTovOfNextDay.isEmpty) && !yomTovOfNextDay.hasPrefix("Erev") && !yomTovOfToday.hasSuffix(yomTovOfNextDay) {
            result.append(yomTovOfToday + " / Erev " + yomTovOfNextDay)
        } else {
            if !yomTovOfToday.isEmpty {
                result.append(yomTovOfToday)
            }
        }
        
        result = addTaanitBechorot(result: result)
        result = addRoshChodesh(result: result)

        if addOmer {
            result = addDayOfOmer(result: result)
        }

        result = replaceChanukahWithDayOfChanukah(result: result)

        return result.joined(separator: " / ")
    }
    
    func addTaanitBechorot(result:Array<String>) -> Array<String> {
        var arr = result
        if tomorrowIsTaanitBechorot() {
            arr.append("Erev Taanit Bechorot")
        }
        if isTaanisBechoros() {
            arr.append("Taanit Bechorot")
        }
        return arr
    }
    
    func tomorrowIsTaanitBechorot() -> Bool {
        let backup = workingDate
        workingDate = workingDate.advanced(by: 86400)
        let result = isTaanisBechoros()
        workingDate = backup
        return result
    }
    
    func addRoshChodesh(result:Array<String>) -> Array<String> {
        var arr = result
        let roshChodeshOrErevRoshChodesh = getRoshChodeshOrErevRoshChodesh()
        if !roshChodeshOrErevRoshChodesh.isEmpty {
            arr.append(roshChodeshOrErevRoshChodesh)
        }
        return arr
    }
    
    func getRoshChodeshOrErevRoshChodesh() -> String {
        var result = ""
        let hebrewDateFormatter = DateFormatter()
        hebrewDateFormatter.calendar = Calendar(identifier: .hebrew)
        hebrewDateFormatter.dateFormat = "MMMM"

        let nextHebrewMonth = hebrewDateFormatter.string(from: workingDate.advanced(by: 86400 * 3))
            .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
            .replacingOccurrences(of: "Tamuz", with: "Tammuz")// advance 3 days into the future, because Rosh Chodesh can be 2 days and we need to know what the next month is at most 3 days before
        
        if isRoshChodesh() {
            result = "Rosh Chodesh " + nextHebrewMonth
        } else if isErevRoshChodesh() {
            result = "Erev Rosh Chodesh " + nextHebrewMonth
        }
        
        return result
    }
    
    func replaceChanukahWithDayOfChanukah(result:Array<String>) -> Array<String> {
        var arr = result
        let dayOfChanukah = dayOfChanukah()
        if dayOfChanukah != -1 {
            if let index = arr.firstIndex(of: "Chanukah") {
                arr.remove(at: index)
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            arr.append(formatter.string(from: dayOfChanukah as NSNumber)! + " day of Chanukah")
        }
        return arr
    }
    
    func dayOfChanukah() -> Int {
        let day = currentHebrewDayOfMonth()
        if isChanukah() {
            if currentHebrewMonth() == HebrewMonth.kislev.rawValue {
                return day - 24
            } else {
                return isKislevShort() ? day + 5 : day + 6
            }
        } else {
            return -1
        }
    }
    
    func addDayOfOmer(result:Array<String>) -> Array<String> {
        var arr = result
        let dayOfOmer = getDayOfOmer()
        if dayOfOmer != -1 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            arr.append(formatter.string(from: dayOfOmer as NSNumber)! + " day of Omer")
        }
        return arr
    }
    
    func getDayOfOmer() -> Int {
        var omer = -1
        let month = currentHebrewMonth()
        let day = currentHebrewDayOfMonth()
        
        if month == HebrewMonth.nissan.rawValue && day >= 16 {
            omer = day - 15
        } else if month == HebrewMonth.iyar.rawValue {
            omer = day + 15
        } else if month == HebrewMonth.sivan.rawValue && day < 6 {
            omer = day + 44
        }
        return omer
    }
    
    func yomTovAsString(index:Int) -> String {
        if index == 33 {
            return "Lag Ba'Omer"
        } else if index == 34 {
            return "Shushan Purim Katan"
        } else if index == 35 {
            return "Isru Chag"
        } else if index != -1 {
            let yomtov = JewishHoliday(index: index).nameTransliterated()
            if yomtov.contains("Shemini Atzeret") {
                if inIsrael {
                    return "Shemini Atzeret & Simchat Torah"
                }
            }
            if yomtov.contains("Simchat Torah") {
                if !inIsrael {
                    return "Shemini Atzeret & Simchat Torah"
                }
            }
            return yomtov
        }
        return ""
    }
    
    func getSpecialParasha() -> String {
        let dayOfWeek = currentDayOfTheWeek()
        let jewishMonth = currentHebrewMonth()
        let jewishDayOfMonth = currentHebrewDayOfMonth()
        let isLeapYear = isCurrentlyHebrewLeapYear()
        
        if dayOfWeek == 7 {
            if (jewishMonth == kHebrewMonth.shevat.rawValue && !isLeapYear) || (jewishMonth == kHebrewMonth.adar.rawValue && isLeapYear) {
                if [25, 27, 29].contains(jewishDayOfMonth) {
                    return "שקלים"
                }
            }
            if (jewishMonth == kHebrewMonth.adar.rawValue && !isLeapYear) || jewishMonth == kHebrewMonth.adar_II.rawValue {
                if jewishDayOfMonth == 1 {
                    return "שקלים"
                }
                if [8, 9, 11, 13].contains(jewishDayOfMonth) {
                    return "זכור"
                }
                if [18, 20, 22, 23].contains(jewishDayOfMonth) {
                    return "פרה"
                }
                if [25, 27, 29].contains(jewishDayOfMonth) {
                    return "החדש"
                }
            }
            if jewishMonth == kHebrewMonth.nissan.rawValue {
                if jewishDayOfMonth == 1 || (jewishDayOfMonth >= 8 && jewishDayOfMonth <= 14) {
                    return "הגדול"
                }
            }
            if jewishMonth == kHebrewMonth.av.rawValue {
                if jewishDayOfMonth >= 4 && jewishDayOfMonth <= 9 {
                    return "חזון"
                }
                if jewishDayOfMonth >= 10 && jewishDayOfMonth <= 16 {
                    return "נחמו"
                }
            }
            if jewishMonth == kHebrewMonth.tishrei.rawValue {
                if jewishDayOfMonth >= 3 && jewishDayOfMonth <= 8 {
                    return "שובה"
                }
            }
            if ParashatHashavuaCalculator().parashaInDiaspora(for: workingDate).name() == "בשלח" {
                return "שירה"
            }
            /* if inIsrael {
                if ParashatHashavuaCalculator().parashaInIsrael(for: workingDate).name() == "בשלח" {
                    return "שירה"
                }
            } else {
                if ParashatHashavuaCalculator().parashaInDiaspora(for: workingDate).name() == "בשלח" {
                    return "שירה"
                }
            } */
        }
        return ""
    }

                
    func isTaanisBechoros() -> Bool {
        let day = currentHebrewDayOfMonth()
        let dayOfWeek = currentDayOfTheWeek()
        //the fast is on the 14th of Nisan unless that is a Shabbos where the fast is moved to Thursday
        return currentHebrewMonth() == HebrewMonth.nissan.rawValue && ((day == 14 && dayOfWeek != 7) || (day == 12 && dayOfWeek == 5))
    }
    
    func getTachanun() -> String {
        let yomTovIndex = yomTovIndex()
        if isRoshChodesh()
            || yomTovIndex == kPesachSheni.rawValue
            || (currentHebrewMonth() == HebrewMonth.iyar.rawValue && currentHebrewDayOfMonth() == 18)//lag baomer
            || yomTovIndex == kTishaBeav.rawValue
            || yomTovIndex == kTuBeav.rawValue
            || yomTovIndex == kErevRoshHashana.rawValue
            || yomTovIndex == kRoshHashana.rawValue
            || yomTovIndex == kErevYomKippur.rawValue
            || yomTovIndex == kYomKippur.rawValue
            || yomTovIndex == kTuBeshvat.rawValue
            || yomTovIndex == kPurimKatan.rawValue
            || (isHebrewLeapYear(currentHebrewYear()) && currentHebrewMonth() == HebrewMonth.adar.rawValue && currentHebrewDayOfMonth() == 15)//shushan purim katan
            || yomTovIndex == kShushanPurim.rawValue
            || yomTovIndex == kPurim.rawValue
            || yomTovIndex == kYomYerushalayim.rawValue
            || isChanukah()
            || currentHebrewMonth() == HebrewMonth.nissan.rawValue
            || (currentHebrewMonth() == HebrewMonth.sivan.rawValue && currentHebrewDayOfMonth() <= 12)
            || (currentHebrewMonth() == HebrewMonth.tishrei.rawValue && currentHebrewDayOfMonth() >= 11) {
            if yomTovIndex == kRoshHashana.rawValue && currentDayOfTheWeek() == 7 {
                return "צדקתך"
            }
            return "No Tachanun today"
        }
        let yomTovIndexForNextDay = getYomTovIndexForNextDay()
        if currentDayOfTheWeek() == 6 //Friday
            || yomTovIndex == kFastOfEsther.rawValue
            || yomTovIndexForNextDay == kTishaBeav.rawValue
            || yomTovIndexForNextDay == kTuBeav.rawValue
            || yomTovIndexForNextDay == kTuBeshvat.rawValue
            || (currentHebrewMonth() == HebrewMonth.iyar.rawValue && currentHebrewDayOfMonth() == 17)// day before lag baomer
            || yomTovIndexForNextDay == kPesachSheni.rawValue
            || yomTovIndexForNextDay == kPurimKatan.rawValue
            || isErevRoshChodesh() {
            if currentDayOfTheWeek() == 7 {
                return "No Tachanun today"
            }
            return "Tachanun only in the morning"
        }
        if currentDayOfTheWeek() == 7 {
            return "צדקתך"
        }
        return "There is Tachanun today"
    }
    
    func getYomTovIndexForNextDay() -> Int {
        //set workingDate to next day
        let temp = workingDate
        workingDate.addTimeInterval(60*60*24)
        let yomTovIndexForTomorrow = yomTovIndex()
        workingDate = temp //reset
        return yomTovIndexForTomorrow
    }
    
    func hasCandleLighting() -> Bool {
        return currentDayOfTheWeek() == 6 || isErevYomTov() || isErevYomTovSheni()
    }
    
    func isErevYomTovSheni() -> Bool {
        return (currentHebrewMonth() == HebrewMonth.tishrei.rawValue && (currentHebrewDayOfMonth() == 1)) || (!inIsrael && ((currentHebrewMonth() == HebrewMonth.nissan.rawValue && (currentHebrewDayOfMonth() == 15 || currentHebrewDayOfMonth() == 21)) || (currentHebrewMonth() == HebrewMonth.tishrei.rawValue && (currentHebrewDayOfMonth() == 15 || currentHebrewDayOfMonth() == 22)) || (currentHebrewMonth() == HebrewMonth.sivan.rawValue && currentHebrewDayOfMonth() == 6 )))
    }
    
    func isAssurBemelacha() -> Bool {
        let holidayIndex = yomTovIndex()
        return currentDayOfTheWeek() == 7 || holidayIndex == kPesach.rawValue || holidayIndex == kShavuos.rawValue || holidayIndex == kSuccos.rawValue || holidayIndex == kSheminiAtzeres.rawValue || holidayIndex == kSimchasTorah.rawValue || holidayIndex == kRoshHashana.rawValue || holidayIndex == kYomKippur.rawValue
    }
    
    func isYomTovAssurBemelacha() -> Bool {
        let holidayIndex = yomTovIndex()
        return holidayIndex == kPesach.rawValue || holidayIndex == kShavuos.rawValue || holidayIndex == kSuccos.rawValue || holidayIndex == kSheminiAtzeres.rawValue || holidayIndex == kSimchasTorah.rawValue || holidayIndex == kRoshHashana.rawValue || holidayIndex == kYomKippur.rawValue
    }
    
    func getHallelOrChatziHallel() -> String {
        let yomTovIndex = yomTovIndex()
        let jewishMonth = currentHebrewMonth()
        let jewishDay = currentHebrewDayOfMonth()
        if (jewishMonth == HebrewMonth.nissan.rawValue && jewishDay == 15) || (!inIsrael && jewishMonth == HebrewMonth.nissan.rawValue && jewishDay == 16) || yomTovIndex == kShavuos.rawValue || yomTovIndex == kSuccos.rawValue || yomTovIndex == kSheminiAtzeres.rawValue || isCholHamoedSuccos() || isChanukah() {
            return "הלל שלם";
        } else if isRoshChodesh() || isCholHamoedPesach() || (jewishMonth == HebrewMonth.nissan.rawValue && jewishDay == 21) || (!inIsrael && jewishMonth == HebrewMonth.nissan.rawValue && jewishDay == 22) {
            return "חצי הלל";
        } else {
            return ""
        }
    }
    
    func getIsUlChaparatPeshaSaid() -> String {
        if isRoshChodesh() {
            if isHebrewLeapYear(currentHebrewYear()) {
                let month = currentHebrewMonth()
                if month == HebrewMonth.tishrei.rawValue || month == HebrewMonth.cheshvan.rawValue || month == HebrewMonth.kislev.rawValue || month == HebrewMonth.teves.rawValue || month == HebrewMonth.shevat.rawValue || month == HebrewMonth.adar.rawValue || month == HebrewMonth.adar_II.rawValue {
                    return "Say וּלְכַפָּרַת פֶּשַׁע";
                } else {
                    return "Do not say וּלְכַפָּרַת פֶּשַׁע";
                }
            } else {
                return "Do not say וּלְכַפָּרַת פֶּשַׁע";
            }
        }
        return ""
    }
    
    func isOKToListenToMusic() -> String {
        if getDayOfOmer() >= 8 && getDayOfOmer() <= 32 {
            return "No Music"
        } else if currentHebrewMonth() == HebrewMonth.tammuz.rawValue {
            if currentHebrewDayOfMonth() >= 17 {
                return "No Music"
            }
        } else if currentHebrewMonth() == HebrewMonth.av.rawValue {
            if currentHebrewDayOfMonth() <= 9 {
                return "No Music"
            }
        }
        return "";
    }
    
    func isAseresYemeiTeshuva() -> Bool {
        return currentHebrewMonth() == HebrewMonth.tishrei.rawValue && currentHebrewDayOfMonth() <= 10;
    }
    
    func isSelichotSaid() -> Bool {
        if currentHebrewMonth() == HebrewMonth.elul.rawValue {
            if !isRoshChodesh() {
                return true;
            }
        }
        return isAseresYemeiTeshuva();
    }
    
    func is3Weeks() -> Bool {
        if currentHebrewMonth() == HebrewMonth.tammuz.rawValue {
            return currentHebrewDayOfMonth() >= 17
        } else if currentHebrewMonth() == HebrewMonth.av.rawValue {
            return currentHebrewDayOfMonth() < 9
        }
        return false
    }
    
    func is9Days() -> Bool {
        if currentHebrewMonth() == HebrewMonth.av.rawValue {
            return currentHebrewDayOfMonth() < 9
        }
        return false
    }
    
    func isShevuahShechalBo() -> Bool {
        if currentHebrewMonth() != HebrewMonth.av.rawValue {
            return false
        }
        
        let backup = workingDate
        
        workingDate = Calendar(identifier: .hebrew).date(bySetting: .day, value: 9, of: workingDate)!
        
        if currentDayOfTheWeek() == 1 || currentDayOfTheWeek() == 7 {
            return false
        }
        workingDate = backup// reset
        
        let tishaBeav = Calendar(identifier: .hebrew).date(bySetting: .day, value: 8, of: workingDate)!
        let jewishCal = JewishCalendar()
        jewishCal.workingDate = tishaBeav
        
        var daysOfShevuahShechalBo = Array<Int>()
        
        while jewishCal.currentDayOfTheWeek() != 7 {
            daysOfShevuahShechalBo.append(jewishCal.currentHebrewDayOfMonth())
            jewishCal.workingDate = jewishCal.workingDate.advanced(by: -86400)
        }
        return daysOfShevuahShechalBo.contains(currentHebrewDayOfMonth())
    }
    
    func isBirkasHachamah() -> Bool {
        var elapsedDays = getJewishCalendarElapsedDays(jewishYear: currentHebrewYear())
        elapsedDays = elapsedDays + getDaysSinceStartOfJewishYear()
        if elapsedDays % Int((28 * 365.25)) == 172 {
            return true
        }
        return false
    }
    
    func getBirchatLevanaStatus() -> String {
        let CHALKIM_PER_DAY = 25920
        let chalakim = getChalakimSinceMoladTohu(year: currentHebrewYear(), month: currentHebrewMonth())
        let moladToAbsDate = (chalakim / CHALKIM_PER_DAY) + (-1373429)
        var year = moladToAbsDate / 366
        while (moladToAbsDate >= gregorianDateToAbsDate(year: year+1,month: 1,dayOfMonth: 1)) {
            year+=1
        }
        var month = 1
        while (moladToAbsDate > gregorianDateToAbsDate(year: year, month: month, dayOfMonth: getLastDayOfGregorianMonth(month: month, year: year))) {
            month+=1
        }
        var dayOfMonth = moladToAbsDate - gregorianDateToAbsDate(year: year, month: month, dayOfMonth: 1) + 1
        if dayOfMonth > getLastDayOfGregorianMonth(month: month, year: year) {
            dayOfMonth = getLastDayOfGregorianMonth(month: month, year: year)
        }
        let conjunctionDay = chalakim / CHALKIM_PER_DAY
        let conjunctionParts = chalakim - conjunctionDay * CHALKIM_PER_DAY
        
        var moladHours = conjunctionParts / 1080
        let moladRemainingChalakim = conjunctionParts - moladHours * 1080
        var moladMinutes = moladRemainingChalakim / 18
        let moladChalakim = moladRemainingChalakim - moladMinutes * 18
        var moladSeconds = Double(moladChalakim * 10 / 3)
        
        moladMinutes = moladMinutes - 20//to get to Standard Time
        moladSeconds = moladSeconds - 56.496//to get to Standard Time
        
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = Calendar.current.timeZone
        
        var moladDay = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "GMT+2")!, year: year, month: month, day: dayOfMonth, hour: moladHours, minute: moladMinutes, second: Int(moladSeconds))
        
        var molad:Date? = nil
        
        if moladHours > 6 {
            moladHours = (moladHours + 18) % 24
            moladDay.day! += 1
            moladDay.setValue(moladHours, for: .hour)
            molad = calendar.date(from: moladDay)
        } else {
            molad = calendar.date(from: moladDay)
        }
        
        let sevenDays = calendar.date(byAdding: .day, value: 7, to: molad!)!

        if currentHebrewMonth() != HebrewMonth.av.rawValue {
            if Calendar.current.isDate(workingDate, inSameDayAs: sevenDays) {
                return "Birchat HaLevana starts tonight";
            }
        } else {
            if currentHebrewDayOfMonth() < 9 {
                return ""
            }
            if yomTovIndex() == kTishaBeav.rawValue {
                return "Birchat HaLevana starts tonight";
            }
        }
        
        if currentHebrewDayOfMonth() == 14 {
            return "Last night for Birchat HaLevana";
        }
        
        let latest = Calendar(identifier: .hebrew).date(bySetting: .day, value: 14, of: sevenDays)!
        
        if workingDate.timeIntervalSince1970 > sevenDays.timeIntervalSince1970 && workingDate.timeIntervalSince1970 < latest.timeIntervalSince1970 {
            let format = DateFormatter()
            format.dateFormat = "MMM d"
            return "Birchat HaLevana until " + format.string(from: latest)
        }
        return ""
    }
    
    func gregorianDateToAbsDate(year:Int, month:Int, dayOfMonth:Int) -> Int {
        var absDate = dayOfMonth
        for m in stride(from: month-1, to: 0, by: -1) {
            absDate += getLastDayOfGregorianMonth(month: m, year: year)
        }
        return (absDate // days this year
                + 365 * (year - 1) // days in previous years ignoring leap days
                + (year - 1) / 4 // Julian leap days before this year
                - (year - 1) / 100 // minus prior century years
        + (year - 1) / 400); // plus prior years divisible by 400
    }
    
    func getLastDayOfGregorianMonth(month:Int, year:Int) -> Int {
        switch month {
        case 2:
            if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                return 29;
            } else {
                return 28;
            }
        case 4:
            return 30;
        case 6:
            return 30;
        case 9:
            return 30;
        case 11:
            return 30;
        default:
            return 31;
        }
    }

    func getIsMashivHaruchOrMoridHatalSaid() -> String {
        if isMashivHaruachRecited() {
            return "משיב הרוח"
        }
        if isMoridHatalRecited() {
            return "מוריד הטל"
        }
        return ""
    }
    
    func getIsBarcheinuOrBarechAleinuSaid() -> String {
        if (isVeseinBerachaRecited()) {
            return "ברכנו";
        } else {
            return "ברך עלינו";
        }
    }

    func isMashivHaruachRecited() -> Bool {
        let calendar = Calendar(identifier: .hebrew)
        let startDateComponents = DateComponents(calendar: calendar, year: currentHebrewYear(), month: 1, day: 22)
        let startDate = calendar.date(from: startDateComponents)!
        let endDateComponents = DateComponents(calendar: calendar, year: currentHebrewYear(), month: 8, day: 15)
        let endDate = calendar.date(from: endDateComponents)!
        return workingDate > startDate && workingDate < endDate
    }
    
    func isMoridHatalRecited() -> Bool {
        return !isMashivHaruachRecited() || isMashivHaruachStartDate() || isMashivHaruachEndDate()
    }
    
    func isMashivHaruachStartDate() -> Bool {
        return currentHebrewMonth() == HebrewMonth.tishrei.rawValue && currentHebrewDayOfMonth() == 22
    }
    
    func isMashivHaruachEndDate() -> Bool {
        return currentHebrewMonth() == HebrewMonth.nissan.rawValue && currentHebrewDayOfMonth() == 15
    }
    
    func isVeseinBerachaRecited() -> Bool {
        return !isVeseinTalUmatarRecited()
    }
    
    func isVeseinTalUmatarRecited() -> Bool {
        if currentHebrewMonth() == HebrewMonth.nissan.rawValue && currentHebrewDayOfMonth() < 15 {
            return true
        }
        if currentHebrewMonth() == HebrewMonth.nissan.rawValue || currentHebrewMonth() == HebrewMonth.iyar.rawValue || currentHebrewMonth() == HebrewMonth.sivan.rawValue || currentHebrewMonth() == HebrewMonth.tammuz.rawValue || currentHebrewMonth() == HebrewMonth.av.rawValue || currentHebrewMonth() == HebrewMonth.elul.rawValue || currentHebrewMonth() == HebrewMonth.tishrei.rawValue {
            return false
        }
        if inIsrael {
            return currentHebrewMonth() != HebrewMonth.cheshvan.rawValue || currentHebrewDayOfMonth() >= 7
        } else {
            let t = getTekufasTishreiElapsedDays()
            return t >= 47;
        }
    }
    
    func getTekufa() -> Double? {
        let INITIAL_TEKUFA_OFFSET = 12.625 // the number of days Tekufas Tishrei occurs before JEWISH_EPOCH

        let days = Double(getJewishCalendarElapsedDays(jewishYear: currentHebrewYear()) + getDaysSinceStartOfJewishYear()) + INITIAL_TEKUFA_OFFSET - 1 // total days since first Tekufas Tishrei event

        let solarDaysElapsed = days.truncatingRemainder(dividingBy: 365.25) // total days elapsed since start of solar year
        let tekufaDaysElapsed = solarDaysElapsed.truncatingRemainder(dividingBy: 91.3125) // the number of days that have passed since a tekufa event
        if (tekufaDaysElapsed > 0 && tekufaDaysElapsed <= 1) { // if the tekufa happens in the upcoming 24 hours
            return ((1.0 - tekufaDaysElapsed) * 24.0).truncatingRemainder(dividingBy: 24) // rationalize the tekufa event to number of hours since start of jewish day
        } else {
            return nil
        }
    }
    
    func getTekufaName() -> String {
        let tekufaNames = ["Tishri", "Tevet", "Nissan", "Tammuz"]
        let INITIAL_TEKUFA_OFFSET = 12.625 // the number of days Tekufas Tishrei occurs before JEWISH_EPOCH

        let days = Double(getJewishCalendarElapsedDays(jewishYear: currentHebrewYear()) + getDaysSinceStartOfJewishYear()) + INITIAL_TEKUFA_OFFSET - 1 // total days since first Tekufas Tishrei event

        let solarDaysElapsed = days.truncatingRemainder(dividingBy: 365.25) // total days elapsed since start of solar year
        let currentTekufaNumber = Int(solarDaysElapsed / 91.3125)
        let tekufaDaysElapsed = solarDaysElapsed.truncatingRemainder(dividingBy: 91.3125) // the number of days that have passed since a tekufa event
        
        if (tekufaDaysElapsed > 0 && tekufaDaysElapsed <= 1) {//if the tekufa happens in the upcoming 24 hours
            return tekufaNames[currentTekufaNumber]
        } else {
            return ""
        }
    }
    
    func getTekufaAsDate() -> Date? {
        let yerushalayimStandardTZ = TimeZone(identifier: "GMT+2")!
        let cal = Calendar(identifier: .gregorian)
        let workingDateComponents = cal.dateComponents([.year, .month, .day], from: workingDate)
        guard let tekufa = getTekufa() else {
            return nil
        }
        let hours = tekufa - 6
        let minutes = Int((hours - Double(Int(hours))) * 60)
        return cal.date(from: DateComponents(calendar: cal, timeZone: yerushalayimStandardTZ, year: workingDateComponents.year, month: workingDateComponents.month, day: workingDateComponents.day, hour: Int(hours), minute: minutes, second: 0, nanosecond: 0))
    }
    
    func getAmudeiHoraahTekufaAsDate() -> Date? {
        let yerushalayimStandardTZ = TimeZone(identifier: "GMT+2")!
        let cal = Calendar(identifier: .gregorian)
        let workingDateComponents = cal.dateComponents([.year, .month, .day], from: workingDate)
        guard let tekufa = getTekufa() else {
            return nil
        }
        let hours = tekufa - 6
        var minutes = Int((hours - Double(Int(hours))) * 60)
        minutes -= 21
        return cal.date(from: DateComponents(calendar: cal, timeZone: yerushalayimStandardTZ, year: workingDateComponents.year, month: workingDateComponents.month, day: workingDateComponents.day, hour: Int(hours), minute: minutes, second: 0, nanosecond: 0))
    }

    
    func getTekufasTishreiElapsedDays() -> Int {
        // Days since Rosh Hashana year 1. Add 1/2 day as the first tekufas tishrei was 9 hours into the day. This allows all
        // 4 years of the secular leap year cycle to share 47 days. Truncate 47D and 9H to 47D for simplicity.
        let days = Double(getJewishCalendarElapsedDays(jewishYear: currentHebrewYear())) + Double(getDaysSinceStartOfJewishYear() - 1) + 0.5
        // days of completed solar years
        let solar = Double(currentHebrewYear() - 1) * 365.25
        return Int(floor(days - solar))
    }
    
    func getDaysSinceStartOfJewishYear() -> Int {
        var elapsedDays = currentHebrewDayOfMonth()
        
        var hebrewMonth = currentHebrewMonth()
        
        if !isHebrewLeapYear(currentHebrewYear()) && hebrewMonth >= 7 {
            hebrewMonth = hebrewMonth - 1//special case for adar 2 because swift is weird
        }
        
        for month in 1..<hebrewMonth {
            elapsedDays += daysInJewishMonth(month: month, year: currentHebrewYear())
        }
        
        return elapsedDays
    }
    
    func daysInJewishMonth(month: Int, year: Int) -> Int {
        if ((month == HebrewMonth.iyar.rawValue) || (month == HebrewMonth.tammuz.rawValue) || (month == HebrewMonth.elul.rawValue) || ((month == HebrewMonth.cheshvan.rawValue) && !(isCheshvanLong(year: year))) || ((month == HebrewMonth.kislev.rawValue) && isKislevShort()) || (month == HebrewMonth.teves.rawValue) || ((month == HebrewMonth.adar.rawValue) && !(isHebrewLeapYear(year))) || (month == HebrewMonth.adar_II.rawValue && isHebrewLeapYear(year))) {
            return 29;
        } else {
            return 30;
        }
    }
    
    func isCheshvanLong(year:Int) -> Bool {
        return length(ofHebrewYear: year) == HebrewYearType.shalaim.rawValue
    }

    func getJewishCalendarElapsedDays(jewishYear: Int) -> Int {
        // The number of chalakim (25,920) in a 24 hour day.
        let CHALAKIM_PER_DAY: Int = 25920 // 24 * 1080
        let chalakimSince = getChalakimSinceMoladTohu(year: jewishYear, month: Int(HebrewMonth.tishrei.rawValue))
        let moladDay = Int(chalakimSince / CHALAKIM_PER_DAY)
        let moladParts = Int(chalakimSince - chalakimSince / CHALAKIM_PER_DAY * CHALAKIM_PER_DAY)
        // delay Rosh Hashana for the 4 dechiyos
        return addDechiyos(year: jewishYear, moladDay: moladDay, moladParts: moladParts)
    }
    
    func getChalakimSinceMoladTohu(year: Int, month: Int) -> Int {
        // The number  of chalakim in an average Jewish month. A month has 29 days, 12 hours and 793 chalakim (44 minutes and 3.3 seconds) for a total of 765,433 chalakim
        let CHALAKIM_PER_MONTH: Int = 765433 // (29 * 24 + 12) * 1080 + 793

        // Days from the beginning of Sunday till molad BaHaRaD. Calculated as 1 day, 5 hours and 204 chalakim = (24 + 5) * 1080 + 204 = 31524
        let CHALAKIM_MOLAD_TOHU: Int = 31524
        // Jewish lunar month = 29 days, 12 hours and 793 chalakim
        // chalakim since Molad Tohu BeHaRaD - 1 day, 5 hours and 204 chalakim
        var monthOfYear = month
        if !isHebrewLeapYear(year) && monthOfYear >= 7 {
            monthOfYear = monthOfYear - 1//special case for adar 2 because swift is weird
        }
        var monthsElapsed = (235 * ((year - 1) / 19))
        monthsElapsed = monthsElapsed + (12 * ((year - 1) % 19))
        monthsElapsed = monthsElapsed + ((7 * ((year - 1) % 19) + 1) / 19)
        monthsElapsed = monthsElapsed + (monthOfYear - 1)
        // return chalakim prior to BeHaRaD + number of chalakim since
        return Int(CHALAKIM_MOLAD_TOHU + (CHALAKIM_PER_MONTH * Int(monthsElapsed)))
    }
    
    func addDechiyos(year: Int, moladDay: Int, moladParts: Int) -> Int {
        var roshHashanaDay = moladDay // if no dechiyos
        // delay Rosh Hashana for the dechiyos of the Molad - new moon 1 - Molad Zaken, 2- GaTRaD 3- BeTuTaKFoT
        if (moladParts >= 19440) || // Dechiya of Molad Zaken - molad is >= midday (18 hours * 1080 chalakim)
            ((moladDay % 7) == 2 && // start Dechiya of GaTRaD - Ga = is a Tuesday
             moladParts >= 9924 && // TRaD = 9 hours, 204 parts or later (9 * 1080 + 204)
             !isHebrewLeapYear(year)) || // of a non-leap year - end Dechiya of GaTRaD
            ((moladDay % 7) == 1 && // start Dechiya of BeTuTaKFoT - Be = is on a Monday
             moladParts >= 16789 && // TRaD = 15 hours, 589 parts or later (15 * 1080 + 589)
             isHebrewLeapYear(year - 1)) { // in a year following a leap year - end Dechiya of BeTuTaKFoT
            roshHashanaDay += 1 // Then postpone Rosh HaShanah one day
        }
        // start 4th Dechiya - Lo ADU Rosh - Rosh Hashana can't occur on A- sunday, D- Wednesday, U - Friday
        if (roshHashanaDay % 7 == 0) || // If Rosh HaShanah would occur on Sunday,
            (roshHashanaDay % 7 == 3) || // or Wednesday,
            (roshHashanaDay % 7 == 5) { // or Friday - end 4th Dechiya - Lo ADU Rosh
            roshHashanaDay += 1 // Then postpone it one (more) day
        }
        return roshHashanaDay
    }
}


public extension DafYomiCalculator {
    
    func dafYomiYerushalmi(calendar: JewishCalendar) -> Daf? {
        let dafYomiStartDay = gregorianDate(forYear: 1980, month: 2, andDay: 2)
        let WHOLE_SHAS_DAFS = 1554
        let BLATT_PER_MASSECTA = [
            68, 37, 34, 44, 31, 59, 26, 33, 28, 20, 13, 92, 65, 71, 22, 22, 42, 26, 26, 33, 34, 22,
            19, 85, 72, 47, 40, 47, 54, 48, 44, 37, 34, 44, 9, 57, 37, 19, 13
        ]
        
        let dateCreator = Calendar(identifier: .gregorian)
        var nextCycle = DateComponents()
        var prevCycle = DateComponents()
        var masechta = 0
        var dafYomi: Daf?
        
        // There isn't Daf Yomi on Yom Kippur or Tisha B'Av.
        if calendar.yomTovIndex() == kYomKippur.rawValue || calendar.yomTovIndex() == kTishaBeav.rawValue {
            return nil
        }
        
        if calendar.workingDate.compare(dafYomiStartDay!) == .orderedAscending {
            return nil
        }
        
        nextCycle.year = 1980
        nextCycle.month = 2
        nextCycle.day = 2
        
//        let n = dateCreator.date(from: nextCycle)
//        let p = dateCreator.date(from: prevCycle)

        // Go cycle by cycle, until we get the next cycle
        while calendar.workingDate.compare(dateCreator.date(from: nextCycle)!) == .orderedDescending {
            prevCycle = nextCycle
            
            nextCycle.day! += WHOLE_SHAS_DAFS
            nextCycle.day! += getNumOfSpecialDays(startDate: dateCreator.date(from: prevCycle)!, endDate: dateCreator.date(from: nextCycle)!)
        }
        
        // Get the number of days from cycle start until request.
        let dafNo = getDiffBetweenDays(start: dateCreator.date(from: prevCycle)!, end: calendar.workingDate.addingTimeInterval(-86400))// this should be a temporary solution. Not sure why the dates are one day off
        
        // Get the number of special day to subtract
        let specialDays = getNumOfSpecialDays(startDate: dateCreator.date(from: prevCycle)!, endDate: calendar.workingDate)
        var total = dafNo - specialDays
        
        // Finally find the daf.
        for j in 0..<BLATT_PER_MASSECTA.count {
            if total < BLATT_PER_MASSECTA[j] {
                dafYomi = Daf(tractateIndex: masechta, andPageNumber: total + 1)
                break
            }
            total -= BLATT_PER_MASSECTA[j]
            masechta += 1
        }
        
        return dafYomi
    }

    private func gregorianDate(forYear year: Int, month: Int, andDay day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.calendar = Calendar(identifier: .gregorian)
        return components.date
    }
    
    func getNumOfSpecialDays(startDate: Date, endDate: Date) -> Int {
        let startCalendar = JewishCalendar()
        startCalendar.workingDate = startDate
        let endCalendar = JewishCalendar()
        endCalendar.workingDate = endDate
        
        var startYear = startCalendar.currentHebrewYear()
        let endYear = endCalendar.currentHebrewYear()
        
        var specialDays = 0
        
        let dateCreator = Calendar(identifier: .hebrew)

        //create a hebrew calendar set to the date 7/10/5770
        var yomKippurComponents = DateComponents()
        yomKippurComponents.year = 5770
        yomKippurComponents.month = 1
        yomKippurComponents.day = 10
        
        var tishaBeavComponents = DateComponents()
        tishaBeavComponents.year = 5770
        tishaBeavComponents.month = 5
        tishaBeavComponents.day = 9
        
        while startYear <= endYear {
            yomKippurComponents.year = startYear
            tishaBeavComponents.year = startYear
            
            if isBetween(start: startDate, date: dateCreator.date(from: yomKippurComponents)!, end: endDate) {
                specialDays += 1
            }
            
            if isBetween(start: startDate, date: dateCreator.date(from: tishaBeavComponents)!, end: endDate) {
                specialDays += 1
            }
            
            startYear += 1
        }

        return specialDays
    }

    func isBetween(start: Date, date: Date, end: Date) -> Bool {
        return (start.compare(date) == .orderedAscending) && (end.compare(date) == .orderedDescending)
    }

    func getDiffBetweenDays(start: Date, end: Date) -> Int {
        let DAY_MILIS: Double = 24 * 60 * 60
        let s = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
        return s / Int(DAY_MILIS)
    }
}

public extension Daf {
    
    func nameYerushalmi() -> String {
        let names = ["ברכות"
                     , "פיאה"
                     , "דמאי"
                     , "כלאים"
                     , "שביעית"
                     , "תרומות"
                     , "מעשרות"
                     , "מעשר שני"
                     , "חלה"
                     , "עורלה"
                     , "ביכורים"
                     , "שבת"
                     , "עירובין"
                     , "פסחים"
                     , "ביצה"
                     , "ראש השנה"
                     , "יומא"
                     , "סוכה"
                     , "תענית"
                     , "שקלים"
                     , "מגילה"
                     , "חגיגה"
                     , "מועד קטן"
                     , "יבמות"
                     , "כתובות"
                     , "סוטה"
                     , "נדרים"
                     , "נזיר"
                     , "גיטין"
                     , "קידושין"
                     , "בבא קמא"
                     , "בבא מציעא"
                     , "בבא בתרא"
                     , "שבועות"
                     , "מכות"
                     , "סנהדרין"
                     , "עבודה זרה"
                     , "הוריות"
                     , "נידה"
                     , "אין דף היום"]

        return names[tractateIndex]
    }
}

extension Int {
    func formatHebrew() -> String {
        if self <= 0 {
            fatalError("Input must be a positive integer")
        }
        var ret = String(repeating: "ת", count: self / 400)
        var num = self % 400
        if num >= 100 {
            ret.append("קרש"[String.Index(utf16Offset: num / 100 - 1, in: "קרש")])
            num %= 100
        }
        switch num {
        // Avoid letter combinations from the Tetragrammaton
        case 16:
            ret.append("טז")
        case 15:
            ret.append("טו")
        default:
            if num >= 10 {
                ret.append("יכלמנסעפצ"[String.Index(utf16Offset: num / 10 - 1, in: "יכלמנסעפצ")])
                num %= 10
            }
            if num > 0 {
                ret.append("אבגדהוזחט"[String.Index(utf16Offset: num - 1, in: "אבגדהוזחט")])
            }
        }
        return ret
    }
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
