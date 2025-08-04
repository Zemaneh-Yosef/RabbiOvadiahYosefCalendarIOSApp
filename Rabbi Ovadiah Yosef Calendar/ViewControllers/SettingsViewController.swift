//
//  SettingsViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/26/23.
//

import UIKit
import MessageUI

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    let length = 18 //increment this every time you want to add...

    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    @IBAction func toggle(_ sender: SwitchWithParam) {
        if sender.param == "showSeconds" {
            let alert = UIAlertController(title: "Do not rely on these seconds!".localized(), message: "DO NOT RELY ON THESE SECONDS. The only zman that can be relied on to the second is the visible sunrise time based on chaitables.com. Otherwise, these zmanim are NOT accurate to the second! You should always round up or down a minute or two just in case.".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
            present(alert, animated: true)
        }
        defaults.set(sender.isOn, forKey: sender.param)
        tableView.reloadData()
        NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return length
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicSettingsCell", for: indexPath)
        cell.accessoryView = nil

        var content = cell.defaultContentConfiguration()
        switch indexPath.row {
        case 0:
            content.text = "Zmanim Settings".localized()
            content.secondaryText = "Change the zmanim settings".localized()
        case 1:
            content.text = "Zmanim Notifications".localized()
            content.secondaryText = "Receive daily zmanim notifications".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "zmanim_notifications")
            switchView.param = "zmanim_notifications"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 2:
            content.text = "Zmanim Notifications Settings".localized()
            content.secondaryText = "Change the zmanim notifications settings".localized()
            if !defaults.bool(forKey: "zmanim_notifications") {
                content.textProperties.color = .gray
                content.secondaryTextProperties.color = .gray
                cell.selectionStyle = .none
            }
        case 3:
            content.text = "Show seconds?".localized()
            content.secondaryText = "Choose whether or not to display the seconds of the zmanim".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "showSeconds")
            switchView.param = "showSeconds"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 4:
            content.text = "Show Rabbeinu Tam everyday?".localized()
            content.secondaryText = "Choose whether or not to display the zman for rabbeinu tam everyday".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "alwaysShowRT")
            switchView.param = "alwaysShowRT"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 5:
            content.text = "Round up Rabbeinu Tam?".localized()
            content.secondaryText = "Choose whether or not to round up the zman for rabbeinu tam to the nearest minute".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "roundUpRT")
            switchView.param = "roundUpRT"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 6:
            content.text = "Notify day of omer as well?".localized()
            content.secondaryText = "Choose whether or not the app will notify you of the day of the omer during the day".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "showDayOfOmer")
            switchView.param = "showDayOfOmer"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 7:
            content.text = "Show zman dialogs?".localized()
            content.secondaryText = "Choose whether or not to display the information for each zman when pressed".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "showZmanDialogs")
            switchView.param = "showZmanDialogs"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 8:
            content.text = "Show when Shabbat/Chag ends the day before?".localized()
            content.secondaryText = "Choose whether or not to add the zman for when shabbat ends on a friday or before chag".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "showWhenShabbatChagEnds")
            switchView.param = "showWhenShabbatChagEnds"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 9:
            content.text = "Show Regular Minutes".localized()
            content.secondaryText = "Show regular minutes the day before shabbat/chag ends".localized()
            if !defaults.bool(forKey: "showWhenShabbatChagEnds") {
                content.textProperties.color = .gray
                content.secondaryTextProperties.color = .gray
                cell.selectionStyle = .none
            } else {
                let switchView = SwitchWithParam(frame: .zero)
                switchView.isOn = defaults.bool(forKey: "showRegularWhenShabbatChagEnds")
                switchView.param = "showRegularWhenShabbatChagEnds"
                switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
                cell.accessoryView = switchView
            }
        case 10:
            content.text = "Show Rabbeinu Tam".localized()
            content.secondaryText = "Show Rabbeinu Tam the day before shabbat/chag ends".localized()
            if !defaults.bool(forKey: "showWhenShabbatChagEnds") {
                content.textProperties.color = .gray
                content.secondaryTextProperties.color = .gray
                cell.selectionStyle = .none
            } else {
                let switchView = SwitchWithParam(frame: .zero)
                switchView.isOn = defaults.bool(forKey: "showRTWhenShabbatChagEnds")
                switchView.param = "showRTWhenShabbatChagEnds"
                switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
                cell.accessoryView = switchView
            }
        case 11:
            content.text = "Always show mishor sunrise?".localized()
            content.secondaryText = "Choose whether or not to display sea level sunrise if visible sunrise is setup as well".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "alwaysShowMishorSunrise")
            switchView.param = "alwaysShowMishorSunrise"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 12:
            content.text = "Show year of Shemita cycle?".localized()
            content.secondaryText = "Show the year of the Shemita cycle or if the current year is a Shemita year".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "showShmita")
            switchView.param = "showShmita"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 13:
            content.text = "Show Shabbat Mevarchim?".localized()
            content.secondaryText = "Choose whether or not to display if shabbat mevarchim happens tomorrow on Friday".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "showShabbatMevarchim")
            switchView.param = "showShabbatMevarchim"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 14:
            content.text = "Set elevation to last known location?".localized()
            content.secondaryText = "Choose whether or not to set the elevation to the last known location when the app is opened offline".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "setElevationToLastKnownLocation")
            switchView.param = "setElevationToLastKnownLocation"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 15:
            content.text = "Have questions or feature requests?".localized()
            content.secondaryText = "Contact the developer".localized()
        case 16:
            content.text = "Haskamot".localized()
            content.secondaryText = "See haskamot rabbanim have given for this app!".localized()
        case 17:
            content.text = "Need help?".localized()
            content.secondaryText = "Watch a video guide".localized()
        default:
            break
        }

        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            showFullScreenView("ZmanimSettingsViewController")
        }
        if indexPath.row == 2 && defaults.bool(forKey: "zmanim_notifications") {
            showFullScreenView("ZmanimNotificationsSettingsViewController")
        }
        if indexPath.row == 3 {
            let alert = UIAlertController(title: "Do not rely on these seconds!".localized(), message: "DO NOT RELY ON THESE SECONDS. The only zman that can be relied on to the second is the visible sunrise time based on chaitables.com. Otherwise, these zmanim are NOT accurate to the second! You should always round up or down a minute or two just in case.".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
            present(alert, animated: true)
        }
        if indexPath.row == 15 {
            let recipient = "elyahujacobi@gmail.com"

            // Check if the user's device can send email
            guard MFMailComposeViewController.canSendMail() else {
                // Display an error message if the device can't send email
                let alert = UIAlertController(title: "Cannot Send Email".localized(), message: "Your device is not configured to send emails. Please send an email from another device to ElyahuJacobi@gmail.com", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }

            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Zemaneh Yosef (iOS)".localized())
            mailComposer.setToRecipients([recipient])

            present(mailComposer, animated: true, completion: nil)
        }
        if indexPath.row == 16 {
            let alertController = UIAlertController(title: "Choose a haskama to view".localized(), message: "Multiple rabbanim have given their haskama/approval to this app. Choose which one you would like to view.".localized(), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Rabbi Yitzchak Yosef (Hebrew)".localized(), style: .default) { (_) in
                if let url = URL(string: "https://royzmanim.com/assets/haskamah-rishon-letzion.pdf") {
                        UIApplication.shared.open(url)
                }
            })
            alertController.addAction(UIAlertAction(title: "Rabbi Elbaz (English)".localized(), style: .default) { (_) in
                if let url = URL(string: "https://royzmanim.com/assets/Haskamah.pdf") {
                        UIApplication.shared.open(url)
                }
            })
            alertController.addAction(UIAlertAction(title: "Rabbi Dahan (Hebrew)".localized(), style: .default) { (_) in
                if let url = URL(string: "https://royzmanim.com/assets/%D7%94%D7%A1%D7%9B%D7%9E%D7%94.pdf") {
                        UIApplication.shared.open(url)
                }
            })
            alertController.addAction(UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in })
            present(alertController, animated: true, completion: nil)
        }
        if indexPath.row == 17 {
            if let url = URL(string: "https://youtu.be/NP1_4kMA-Vs") {
                    UIApplication.shared.open(url)
            }
        }
    }

}

class SwitchWithParam: UISwitch {
    var param: String = ""
    var paramWithoutNotify = ""
}

