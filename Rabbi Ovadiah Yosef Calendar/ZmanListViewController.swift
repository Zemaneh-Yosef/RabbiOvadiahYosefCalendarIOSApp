//
//  ViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 2/10/23.
//

import UIKit
import KosherCocoa
import CoreLocation

class ZmanListViewController: UITableViewController {
    
    var locationName: String = ""
    var lat: Double = 0
    var long: Double = 0
    var elevation: Double = 0.0
    var timezone: TimeZone = TimeZone.current
    var shabbatMode: Bool = false
    var userChosenDate: Date = Date()
    var nextUpcomingZman: Date? = nil
    var zmanimCalendar: ComplexZmanimCalendar = ComplexZmanimCalendar()
    var jewishCalendar: JewishCalendar = JewishCalendar()
    let defaults = UserDefaults.standard
    var zmanimList = Array<ZmanListEntry>()
    let dateFormatterForZmanim = DateFormatter()
    var timerForShabbatMode: Timer?
    var timerForNextZman: Timer?
    var currentIndex = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func prevDayButton(_ sender: Any) {
        userChosenDate = userChosenDate.advanced(by: -86400)
        syncCalendarDates()
        updateZmanimList()
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
                if self.defaults.bool(forKey: "useElevation") {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zmanimList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ZmanEntry", for: indexPath)
        var zman = zmanimList[indexPath.row].zman
        
        var content = cell.defaultContentConfiguration()
            content.textProperties.adjustsFontSizeToFitWidth = true
            content.textProperties.numberOfLines = 1
            
            if zmanimList[indexPath.row].isZman {
                if zman == nil {
                    content.text = zmanimList[indexPath.row].title
                    content.secondaryText = "N/A"
                } else {
                    content.text = zmanimList[indexPath.row].title
                    if zman == nextUpcomingZman {
                        let arrow = "➤"
                        if zmanimList[indexPath.row].isRTZman && defaults.bool(forKey: "roundUpRT") {
                            zman = zman?.advanced(by: 60)
                            let roundedFormat = DateFormatter()
                            roundedFormat.dateFormat = "h:mm aa"
                            content.secondaryText = arrow + roundedFormat.string(from: zman!)
                        } else {
                            content.secondaryText = arrow + dateFormatterForZmanim.string(from: zman!)
                        }
                    } else {
                        if zmanimList[indexPath.row].isRTZman && defaults.bool(forKey: "roundUpRT") {
                            zman = zman?.advanced(by: 60)
                            let roundedFormat = DateFormatter()
                            roundedFormat.dateFormat = "h:mm aa"
                            content.secondaryText = roundedFormat.string(from: zman!)
                        } else {
                            content.secondaryText = dateFormatterForZmanim.string(from: zman!)
                        }                    }
                }
                content.textProperties.font = .boldSystemFont(ofSize: 20)
                content.secondaryTextProperties.font = .boldSystemFont(ofSize: 20)
                content.prefersSideBySideTextAndSecondaryText = true
            } else {
                content.textProperties.alignment = .center
                content.text = zmanimList[indexPath.row].title
            }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if shabbatMode || !defaults.bool(forKey: "showZmanDialogs"){
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
            let elevationAction = UIAlertAction(title: "Set Elevation", style: .default) { [self] (_) in
                self.setupElevetion((Any).self)
            }
            alertController.addAction(elevationAction)
        }

        let dismissAction = UIAlertAction(title: "Dismiss", style: .default) { (_) in }
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
            SharedData.shared.lat = lat
            SharedData.shared.long = long
            elevation = defaults.double(forKey: "elevation" + locationName)
            timezone = TimeZone.init(identifier: defaults.string(forKey: "timezone")!)!
            recreateZmanimCalendar()
        } else {
            getUserLocation()
        }
        userChosenDate = Date()
        syncCalendarDates()
        updateZmanimList()
        tableView.refreshControl?.endRefreshing()
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
        tableView.refreshControl = refreshControl
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
        tableView.addGestureRecognizer(swipeGestureRecognizer)
        tableView.addGestureRecognizer(swipeLeftGestureRecognizer)
        createMenu()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        ShabbatModeBanner.isUserInteractionEnabled = true
        ShabbatModeBanner.addGestureRecognizer(tapGestureRecognizer)
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
                SharedData.shared.lat = lat
                SharedData.shared.long = long
                if self.defaults.object(forKey: "elevation" + self.locationName) != nil {//if we have been here before, use the elevation saved for this location
                    self.elevation = self.defaults.double(forKey: "elevation" + self.locationName)
                } else {//we have never been here before, get the elevation from online
                    if self.defaults.bool(forKey: "useElevation") {
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
        createBackgroundThreadForNextUpcomingZman()
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
        userChosenDate = Date()
        syncCalendarDates()
        updateZmanimList()
        shabbatMode = true
        prevDayButton.isEnabled = false
        calendarButton.isEnabled = false
        nextDayButton.isEnabled = false
        ShabbatModeBanner.speed = .rate(15)
        ShabbatModeBanner.animationCurve = .linear
        setShabbatBannerColors(isFirstTime:true)
        ShabbatModeBanner.isHidden = false
        startBackgroundScrollingThread()
        scheduleTimer()
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
        DispatchQueue.global(qos: .background).async {
            while self.shabbatMode {
                for row in 0..<self.zmanimList.count {
                    DispatchQueue.main.async {
                        if self.shabbatMode {
                            let indexPath = IndexPath(row: row, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                        }
                    }
                    
                    Thread.sleep(forTimeInterval: 0.5)
                }
                for row in (0..<self.zmanimList.count).reversed() {
                    DispatchQueue.main.async {
                        if self.shabbatMode {
                            let indexPath = IndexPath(row: row, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                        }
                    }
                    
                    Thread.sleep(forTimeInterval: 0.5)
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
        temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.alos72Zmanis(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.talitTefilin(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
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
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString(), zman:zmanimCalendar.plagHamincha(), isZman: true))
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
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzaisAteretTorah(), isZman: true))
                    }
                    if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                        temp.append(ZmanListEntry(title: zmanimNames.getRTString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzais72Zmanis(), isZman: true))
                    }
                }
                jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: -86400)
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
            }
        }
        temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.sunset(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.tzeit(), isZman: true))
        if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.currentDayOfTheWeek() != 6 {
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzeit(), isZman: true, isNoteworthyZman: true))
        }
        if jewishCalendar.isTaanis() && jewishCalendar.yomTovIndex() != kYomKippur.rawValue {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzeitTaanit(), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.tzeitTaanitLChumra(), isZman: true, isNoteworthyZman: true))
        }
        if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
            zmanimCalendar.ateretTorahSunsetOffset = 40
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
        temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.alotAmudeiHoraah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.talitTefilinAmudeiHoraah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
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
        temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.sunset(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.tzaitAmudeiHoraah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.tzaitAmudeiHoraahLChumra(), isZman: true))
        if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.currentDayOfTheWeek() != 6 {
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaitAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        }
        if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72ZmanitAmudeiHoraahLkulah(), isZman: true, isNoteworthyZman: true, isRTZman: true))
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
                SharedData.shared.lat = lat
                SharedData.shared.long = long
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
                        if self.defaults.bool(forKey: "useElevation") {
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
    
    @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            if gestureRecognizer.direction == .left {
                nextDayButton((Any).self)
            }
            if gestureRecognizer.direction == .right {
                prevDayButton((Any).self)
            }
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
        let specialDay = jewishCalendar.getSpecialDay()
        if !specialDay.isEmpty {
            zmanimList.append(ZmanListEntry(title:specialDay))
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
        let bircatHelevana = jewishCalendar.getIsTonightStartOrEndBircatLevana()
        if !bircatHelevana.isEmpty {
            zmanimList.append(ZmanListEntry(title: bircatHelevana))
        }
        if jewishCalendar.isBirkasHachamah() {
            zmanimList.append(ZmanListEntry(title: "Birchat HaChamah is said today"))
        }
        dateFormatter.dateFormat = "h:mm aa"
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
                    zmanimList.append(ZmanListEntry(title:"Daf Yomi Yerushalmi: " +  yerushalmiYomi!.nameYerushalmi() + " " + yerushalmiYomi!.pageNumber.formatHebrew()))
                } else {
                    zmanimList.append(ZmanListEntry(title:"No Daf Yomi Yerushalmi"))
                }
            }
        }
        zmanimList.append(ZmanListEntry(title:jewishCalendar.getIsMashivHaruchOrMoridHatalSaid() + " / " + jewishCalendar.getIsBarcheinuOrBarechAleinuSaid()))
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        zmanimList.append(ZmanListEntry(title:"GRA: " + (formatter.string(from: TimeInterval(zmanimCalendar.shaahZmanisGra())) ?? "N/A") + " / " + "MGA: " + (formatter.string(from: TimeInterval(zmanimCalendar.shaahZmanis72MinutesZmanis())) ?? "N/A")))
        tableView.reloadData()
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
                                      message: "You can choose to use your device's location, or you can search for a place below. It is recommended to use your devices location as this provides more accurate results.", preferredStyle: .alert)
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
                if let locality = i?.first?.locality {
                    name += locality
                }
                if let adminRegion = i?.first?.administrativeArea {
                    name += ", \(adminRegion)"
                }
                if name.isEmpty {
                    name = "No location name info"
                }
                self.locationName = name
                let coordinates = i?.first?.location?.coordinate
                self.lat = coordinates?.latitude ?? 0
                self.long = coordinates?.longitude ?? 0
                SharedData.shared.lat = self.lat
                SharedData.shared.long = self.long
                if self.defaults.object(forKey: "elevation" + self.locationName) != nil {//if we have been here before, use the elevation saved for this location
                    self.elevation = self.defaults.double(forKey: "elevation" + self.locationName)
                } else {//we have never been here before, get the elevation from online
                    if self.defaults.bool(forKey: "useElevation") {
                        self.getElevationFromOnline()
                    }
                    self.elevation = 0//undo any previous values
                }
                self.timezone = (i?.first?.timeZone)!
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
        let amount = notification.object as! String
        elevation = NumberFormatter().number(from: amount)!.doubleValue
        defaults.set(elevation, forKey: "elevation" + locationName)
        recreateZmanimCalendar()
    }
    
    public func recreateZmanimCalendar() {
        zmanimCalendar = ComplexZmanimCalendar(location: GeoLocation(name: locationName, andLatitude: lat, andLongitude: long, andElevation: elevation, andTimeZone: timezone))
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
    
    override func seaLevelSunset() -> Date? {
        if GlobalStruct.useElevation {
            return super.sunset()
        }
        return super.seaLevelSunset()
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
    
    override func sunrise() -> Date? {
        if GlobalStruct.useElevation {
            return super.sunrise()
        }
        return super.seaLevelSunrise()
    }
    
    override func seaLevelSunrise() -> Date? {
        if GlobalStruct.useElevation {
            return super.sunrise()
        }
        return super.seaLevelSunrise()
    }
    
    func seaLevelSunriseOnly() -> Date? {
        return super.seaLevelSunrise()
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
        let sunrise = sunrise()
        let sunset = sunset()
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
        let numberOfSeconds = ((sunrise()!.timeIntervalSince1970 - alotBy16Degrees!.timeIntervalSince1970))
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunriseOnly()?.addingTimeInterval(-(numberOfSeconds * secondsZmanit));
    }
    
    func talitTefilinAmudeiHoraah() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let alotBy16Degrees = sunriseOffset(byDegrees:90 + 16.04)
        let numberOfSeconds = ((sunrise()!.timeIntervalSince1970 - alotBy16Degrees!.timeIntervalSince1970))
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunriseOnly()?.addingTimeInterval(-(numberOfSeconds * secondsZmanit * 5 / 6));
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
        let tzaitGeonimInDegrees = sunsetOffset(byDegrees:90 + 3.75)
        let numberOfSeconds = (tzaitGeonimInDegrees!.timeIntervalSince1970 - sunset()!.timeIntervalSince1970)
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
        let tzaitGeonimInDegrees = sunsetOffset(byDegrees:90 + 5.3)
        let numberOfSeconds = (tzaitGeonimInDegrees!.timeIntervalSince1970 - sunset()!.timeIntervalSince1970)
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
        let tzaitRTInDegrees = sunsetOffset(byDegrees:90 + 16.0)
        let numberOfSeconds = (tzaitRTInDegrees!.timeIntervalSince1970 - sunset()!.timeIntervalSince1970)
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
        return sunsetOffset(byDegrees: 90 + 7.18)
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
    
    func getSpecialDay() -> String {
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
        result = addDayOfOmer(result: result)
        result = replaceChanukahWithDayOfChanukah(result: result)

        return result.joined(separator: " / ")
    }
    
    func getSpecialDayWithoutOmer() -> String {
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

        let hebrewMonth = hebrewDateFormatter.string(from: workingDate)
        
        if isRoshChodesh() {
            result = "Rosh Chodesh " + hebrewMonth
        } else if isErevRoshChodesh() {
            result = "Erev Rosh Chodesh " + hebrewDateFormatter.string(from: workingDate.advanced(by: 86400))
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
        if currentDayOfTheWeek() == 7 {
            if (currentHebrewMonth() == kHebrewMonth.shevat.rawValue && !isCurrentlyHebrewLeapYear()) || (currentHebrewMonth() == kHebrewMonth.adar.rawValue && isCurrentlyHebrewLeapYear()) {
                if [25, 27, 29].contains(currentHebrewDayOfMonth()) {
        return "שקלים"
        }
        }
            if (currentHebrewMonth() == kHebrewMonth.adar.rawValue && !isCurrentlyHebrewLeapYear()) || currentHebrewMonth() == kHebrewMonth.adar_II.rawValue {
        if currentHebrewDayOfMonth() == 1 {
        return "שקלים"
        }
        if [8, 9, 11, 13].contains(currentHebrewDayOfMonth()) {
        return "זכור"
        }
        if [18, 20, 22, 23].contains(currentHebrewDayOfMonth()) {
        return "פרה"
        }
        if [25, 27, 29].contains(currentHebrewDayOfMonth()) {
        return "החדש"
        }
        }
        if currentHebrewMonth() == kHebrewMonth.nissan.rawValue && currentHebrewDayOfMonth() == 1 {
        return "החדש"
        }
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
            return "There is no Tachanun today"
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
                return "There is no Tachanun today"
            }
            return "There is only Tachanun in the morning"
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
                if month == HebrewMonth.cheshvan.rawValue || month == HebrewMonth.kislev.rawValue || month == HebrewMonth.teves.rawValue || month == HebrewMonth.shevat.rawValue || month == HebrewMonth.adar.rawValue || month == HebrewMonth.adar_II.rawValue {
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
    
    func isBirkasHachamah() -> Bool {
        var elapsedDays = getJewishCalendarElapsedDays(jewishYear: currentHebrewYear())
        elapsedDays = elapsedDays + getDaysSinceStartOfJewishYear()
        if elapsedDays % Int((28 * 365.25)) == 172 {
            return true
        }
        return false
    }
    
    func getIsTonightStartOrEndBircatLevana() -> String {
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

        if Calendar.current.isDate(workingDate, inSameDayAs: sevenDays) {
            return "Birchat HaLevana starts tonight";
        }
        
        if currentHebrewDayOfMonth() == 14 {
            return "Last night for Birchat HaLevana";
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
        let dafNo = getDiffBetweenDays(start: dateCreator.date(from: prevCycle)!, end: calendar.workingDate)
        
        // Get the number of special day to subtract
        let specialDays = getNumOfSpecialDays(startDate: dateCreator.date(from: prevCycle)!, endDate: calendar.workingDate)
        var total = dafNo - specialDays
        
        // Finally find the daf.
        for j in 0..<BLATT_PER_MASSECTA.count {
            if total < BLATT_PER_MASSECTA[j] {
                dafYomi = Daf(tractateIndex: masechta, andPageNumber: total + 1)
                break
            }
            masechta += 1
            total -= BLATT_PER_MASSECTA[j]
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
                     , "כלאיים"
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


class SharedData {
    static let shared = SharedData()
    var lat: Double = 0.0
    var long: Double = 0.0
    private init() {}
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


