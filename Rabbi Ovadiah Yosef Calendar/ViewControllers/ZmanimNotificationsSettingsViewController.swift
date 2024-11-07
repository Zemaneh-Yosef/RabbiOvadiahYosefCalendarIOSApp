//
//  ZmanimNotificationsSettingsViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/28/23.
//

import UIKit

class ZmanimNotificationsSettingsViewController: UITableViewController {
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard

    var editableZmanim = ["Alot Hashachar",
                          "Talit And Tefilin",
                          "Sunrise",
                          "Sof Zman Shma MGA",
                          "Sof Zman Shma GRA",
                          "Sof Zman Tefila",
                          "Achilat Chametz",
                          "Biur Chametz",
                          "Chatzot",
                          "Mincha Gedolah",
                          "Mincha Ketana",
                          "Plag HaMincha Halacha Berurah",
                          "Plag HaMincha Yalkut Yosef",
                          "Candle Lighting",
                          "Sunset",
                          "Tzeit Hacochavim",
                          "Tzeit Hacochavim (Stringent)",
                          "Fast Ends",
                          "Shabbat Ends",
                          "Rabbeinu Tam",
                          "Chatzot Layla"]

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func toggle(_ sender: SwitchWithParam) {
        defaults.set(sender.isOn, forKey: sender.param)
        if !sender.isOn {
            defaults.set(-1, forKey: sender.paramWithoutNotify)
        } else {
            defaults.set(0, forKey: sender.paramWithoutNotify)
        }
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if !defaults.bool(forKey: "LuachAmudeiHoraah") {
            if defaults.integer(forKey: "plagOpinion") == 1 {
                editableZmanim.remove(at: editableZmanim.firstIndex(of: "Plag HaMincha Halacha Berurah")!)
            }
            if defaults.integer(forKey: "plagOpinion") == 2 {
                editableZmanim.remove(at: editableZmanim.firstIndex(of: "Plag HaMincha Yalkut Yosef")!)
            }
            if !defaults.bool(forKey: "showTzeitLChumra") {
                editableZmanim.remove(at: editableZmanim.firstIndex(of: "Tzeit Hacochavim (Stringent)")!)
            }
        } else {
            editableZmanim.remove(at: editableZmanim.firstIndex(of: "Fast Ends")!)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + editableZmanim.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicSettingsCell", for: indexPath)
        cell.accessoryView = nil
        
        var content = cell.defaultContentConfiguration()
        switch indexPath.row {
        case 0:
            content.text = "Zmanim Notifications on Shabbat and Yom Tov".localized()
            content.secondaryText = "Receive zmanim notifications on shabbat and yom tov".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "zmanim_notifications_on_shabbat")
            switchView.param = "zmanim_notifications_on_shabbat"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 1:
            content.text = "Minutes before the zman for notifications".localized()
            content.secondaryText = "Select on the row of the zman to change the amount of minutes".localized()
            content.textProperties.alignment = .center
            content.secondaryTextProperties.alignment = .center
        case 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23:
            if !defaults.bool(forKey: "Notify" + editableZmanim[indexPath.row-2]) {
                content.textProperties.color = .gray
                content.secondaryTextProperties.color = .gray
                cell.selectionStyle = .none
            }
            if !defaults.bool(forKey: "LuachAmudeiHoraah") && defaults.integer(forKey: "plagOpinion") == 1 {
                content.text = editableZmanim[indexPath.row-2].replacingOccurrences(of: "Plag HaMincha Yalkut Yosef", with: "Plag HaMincha").localized()
            } else {
                content.text = editableZmanim[indexPath.row-2].localized()
            }
            let minutesBefore = defaults.integer(forKey: editableZmanim[indexPath.row-2])
            if minutesBefore >= 1 {
                content.secondaryText = "Notify ".localized() + String(minutesBefore) + " minutes before".localized()
            } else if minutesBefore == 0 {
                content.secondaryText = "Notify at the time of the zman".localized()
            } else {
                content.secondaryText = "Off".localized()
            }
            if !defaults.bool(forKey: "Notify" + editableZmanim[indexPath.row-2]) {
                content.secondaryText = "Off".localized()
            }
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "Notify" + editableZmanim[indexPath.row-2])
            switchView.param = "Notify" + editableZmanim[indexPath.row-2]
            switchView.paramWithoutNotify = editableZmanim[indexPath.row-2]
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        default:
            break
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                
        if indexPath.row >= 2 && self.defaults.bool(forKey: "Notify" + editableZmanim[indexPath.row-2]) {
            let alertController = UIAlertController(title: editableZmanim[indexPath.row-2].localized(), message:"Enter how many minutes before you would like to be notified for ".localized() + editableZmanim[indexPath.row-2].localized(), preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = "Minutes".localized()
            }

            let saveAction = UIAlertAction(title: "Save".localized(), style: .default) { [weak alertController] (_) in
                let textField = alertController?.textFields![0]
                self.defaults.set(Int(textField?.text ?? "0"), forKey: self.editableZmanim[indexPath.row-2])
                self.tableView.reloadData()
            }
            alertController.addAction(saveAction)

            present(alertController, animated: true, completion: nil)
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
