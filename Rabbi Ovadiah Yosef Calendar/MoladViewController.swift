//
//  MoladViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/21/23.
//

import UIKit
import KosherCocoa

class MoladViewController: UIViewController {
    
    let jewishCalendar = JewishCalendar()

    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    @IBOutlet weak var changeMonthButton: UIButton!
    @IBOutlet weak var chosenMonth: UILabel!
    @IBAction func changeMonth(_ sender: Any) {
        showDatePicker()
    }
    @IBOutlet weak var moladChalakim: UILabel!
    @IBOutlet weak var molad: UILabel!
    @IBOutlet weak var earliestBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignBackground()
        setLabelTexts()
        if #available(iOS 15.0, *) {
            changeMonthButton.configuration = .filled()
            changeMonthButton.configuration?.background.backgroundColor = .systemBlue
            changeMonthButton.tintColor = .black
        }
    }
    
    func assignBackground() {
        let background = UIImage(named: "molad_background")

        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    func setLabelTexts() {
        let CHALKIM_PER_DAY = 25920
        let chalakim = jewishCalendar.getChalakimSinceMoladTohu(year: jewishCalendar.currentHebrewYear(), month: jewishCalendar.currentHebrewMonth())
        let moladToAbsDate = (chalakim / CHALKIM_PER_DAY) + (-1373429)
        var year = moladToAbsDate / 366
        while (moladToAbsDate >= jewishCalendar.gregorianDateToAbsDate(year: year+1,month: 1,dayOfMonth: 1)) {
            year+=1
        }
        var month = 1
        while (moladToAbsDate > jewishCalendar.gregorianDateToAbsDate(year: year, month: month, dayOfMonth: jewishCalendar.getLastDayOfGregorianMonth(month: month, year: year))) {
            month+=1
        }
        var dayOfMonth = moladToAbsDate - jewishCalendar.gregorianDateToAbsDate(year: year, month: month, dayOfMonth: 1) + 1
        if dayOfMonth > jewishCalendar.getLastDayOfGregorianMonth(month: month, year: year) {
            dayOfMonth = jewishCalendar.getLastDayOfGregorianMonth(month: month, year: year)
        }
        let conjunctionDay = chalakim / CHALKIM_PER_DAY
        let conjunctionParts = chalakim - conjunctionDay * CHALKIM_PER_DAY
        
        var moladHours = conjunctionParts / 1080
        let moladRemainingChalakim = conjunctionParts - moladHours * 1080
        let moladMinutesOG = moladRemainingChalakim / 18
        let moladChalakimOG = moladRemainingChalakim - moladMinutesOG * 18
        var moladSeconds = Double(moladChalakimOG * 10 / 3)
        
        let moladMinutes = moladMinutesOG - 20//to get to Standard Time
        moladSeconds = moladSeconds - 56.496//to get to Standard Time
        
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = Calendar.current.timeZone
        
        var moladDay = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "GMT+2")!, year: year, month: month, day: dayOfMonth, hour: moladHours, minute: moladMinutes, second: Int(moladSeconds))
        
        var moladDate:Date? = nil//made it nil to copy java but probably can be refactored
        
        if moladHours > 6 {
            moladHours = (moladHours + 18) % 24
            moladDay.day! += 1
            moladDay.setValue(moladHours, for: .hour)
            moladDate = calendar.date(from: moladDay)
        } else {
            moladDate = calendar.date(from: moladDay)
        }
        
        let sevenDays = calendar.date(byAdding: .day, value: 7, to: moladDate!)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM d h:mm:ss a"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        let hebrewMonthFormatter = DateFormatter()
        hebrewMonthFormatter.calendar = Calendar.init(identifier: .hebrew)
        hebrewMonthFormatter.dateFormat = "MMMM yyyy"
        
        chosenMonth.text = monthFormatter.string(from: jewishCalendar.workingDate) + " / " + hebrewMonthFormatter.string(from: jewishCalendar.workingDate)
        moladChalakim.text = String(moladHours) + "h:" + String(moladMinutesOG) + "m and " + String(moladChalakimOG) + " Chalakim"
        molad.text = formatter.string(from: moladDate!)
        earliestBL.text = formatter.string(from: sevenDays)
    }
    
    @objc func showDatePicker() {
        let alertController = UIAlertController(title: "Select a date", message: nil, preferredStyle: .actionSheet)

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = jewishCalendar.workingDate
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
            self.showHebrewDatePicker()
        }

        alertController.addAction(changeCalendarAction)

        let doneAction = UIAlertAction(title: "Done", style: .default) { (_) in
            self.setLabelTexts()
        }

        alertController.addAction(doneAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showHebrewDatePicker() {
        let alertController = UIAlertController(title: "Select a date", message: nil, preferredStyle: .actionSheet)

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.calendar = Calendar(identifier: .hebrew)
        datePicker.locale = Locale(identifier: "he")
        datePicker.date = jewishCalendar.workingDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(datePicker)

        // Add constraints to the date picker that pin it to the edges of the alert controller's view
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 32).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -32).isActive = true
        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 64).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -96).isActive = true
        
        let changeCalendarAction = UIAlertAction(title: "Switch Calendar", style: .default) { (_) in
            self.showDatePicker()
        }

        alertController.addAction(changeCalendarAction)

        let doneAction = UIAlertAction(title: "Done", style: .default) { (_) in
            self.setLabelTexts()
        }

        alertController.addAction(doneAction)

        present(alertController, animated: true, completion: nil)
    }

    // Function to handle changes to the date picker value
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        jewishCalendar.workingDate = sender.date
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
