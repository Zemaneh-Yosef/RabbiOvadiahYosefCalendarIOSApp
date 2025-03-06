//
//  MoladViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/21/23.
//

import UIKit
import KosherSwift

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
        let calendar = Calendar.init(identifier: .gregorian)
        
        let moladDate = jewishCalendar.getMoladAsDate()
        
        let sevenDays = calendar.date(byAdding: .day, value: 7, to: moladDate)!
        
        let formatter = DateFormatter()
        if Locale.isHebrewLocale() {
            formatter.dateFormat = "E MMM d H:mm:ss"
        } else {
            formatter.dateFormat = "E MMM d h:mm:ss a"
        }
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        let hebrewMonthFormatter = DateFormatter()
        hebrewMonthFormatter.calendar = Calendar.init(identifier: .hebrew)
        hebrewMonthFormatter.dateFormat = "MMMM yyyy"
        
        chosenMonth.text = monthFormatter.string(from: jewishCalendar.workingDate) + " / " + hebrewMonthFormatter.string(from: jewishCalendar.workingDate).replacingOccurrences(of: "Heshvan", with: "Cheshvan")
            .replacingOccurrences(of: "Tamuz", with: "Tammuz")
        jewishCalendar.calculateMolad()
        moladChalakim.text = String(jewishCalendar.moladHours) + "h:".localized() + String(jewishCalendar.moladMinutes) + "m and ".localized() + String(jewishCalendar.moladChalakim) + " Chalakim".localized()
        molad.text = formatter.string(from: moladDate)
        earliestBL.text = formatter.string(from: sevenDays)
    }
    
    @objc func showDatePicker() {
        var alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .actionSheet)

        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .alert)
        }
        
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
        
        let changeCalendarAction = UIAlertAction(title: "Switch Calendar".localized(), style: .default) { (_) in
            self.showHebrewDatePicker()
        }

        alertController.addAction(changeCalendarAction)

        let doneAction = UIAlertAction(title: "Done".localized(), style: .default) { (_) in
            self.setLabelTexts()
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
        datePicker.date = jewishCalendar.workingDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(datePicker)

        // Add constraints to the date picker that pin it to the edges of the alert controller's view
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 32).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -32).isActive = true
        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 64).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -96).isActive = true
        
        let changeCalendarAction = UIAlertAction(title: "Switch Calendar".localized(), style: .default) { (_) in
            self.showDatePicker()
        }

        alertController.addAction(changeCalendarAction)

        let doneAction = UIAlertAction(title: "Done".localized(), style: .default) { (_) in
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
