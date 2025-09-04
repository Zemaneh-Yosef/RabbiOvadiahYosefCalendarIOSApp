//
//  ZmanimSettingsViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/28/23.
//

import UIKit

class ZmanimSettingsViewController: UITableViewController {
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    
    let amudeiHoraahRow = 0
    let tekufaRow = 1
    let candleLightingRow = 2
    let overrideTimeForShabbat = 3
    let minutesForShabbatEndRow = 4
    let endShabbatOpinionRow = 5
    let alwaysCalcTenthOfDayRow = 6
    let amountOfRows = 6 + 1 // it should be the last row + 1

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func toggle(_ sender: SwitchWithParam) {
        defaults.set(sender.isOn, forKey: sender.param)
        tableView.reloadData()
        NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return amountOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicSettingsCell", for: indexPath)
        cell.accessoryView = nil

        var content = cell.defaultContentConfiguration()
        switch indexPath.row {
        case amudeiHoraahRow:
            content.text = "Amudei Horaah Mode".localized()
            content.secondaryText = "Apply a deviation to the zmanim like the Amudei Horaah calendar does (Only outside Israel)".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "LuachAmudeiHoraah")
            switchView.param = "LuachAmudeiHoraah"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case tekufaRow:
            content.text = "Tekufa Opinion".localized()
            content.secondaryText = "Choose which opinion to use for the time for the tekufas".localized()
        case candleLightingRow:
            content.text = "Candle Lighting Time".localized()
            content.secondaryText = "Enter the amount of minutes for candle lighting".localized()
        case overrideTimeForShabbat:
            content.text = "Override the time for Shabbat End".localized()
            content.secondaryText = "Override the time for when shabbat ends to use the below settings".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "overrideAHEndShabbatTime")
            switchView.param = "overrideAHEndShabbatTime"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case minutesForShabbatEndRow:
            content.text = "Minutes till shabbat ends".localized()
            content.secondaryText = "Enter the amount of minutes to add to sunset for shabbat/chag to end".localized()
            if !defaults.bool(forKey: "overrideAHEndShabbatTime") {
                content.textProperties.color = .secondaryLabel
                content.secondaryTextProperties.color = .secondaryLabel
            }
        case endShabbatOpinionRow:
            content.text = "End shabbat opinion".localized()
            content.secondaryText = "Choose which opinion to use for the time for when shabbat/chag ends".localized()
            if !defaults.bool(forKey: "overrideAHEndShabbatTime") {
                content.textProperties.color = .secondaryLabel
                content.secondaryTextProperties.color = .secondaryLabel
            }
        case alwaysCalcTenthOfDayRow:
            content.text = "Always use a 10th of the day for Rabbeinu Tam".localized()
            content.secondaryText = "Enable this if you want to always calculate Rabbeinu Tam as a 10th of the day (72 non-deviated zmaniyot minutes)".localized()
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "overrideRTZman")
            switchView.param = "overrideRTZman"
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
        
        if indexPath.row == candleLightingRow {
            let alertController = UIAlertController(title: "Candle Lighting Time".localized(), message:"Set how many minutes before sunset is candle lighting".localized(), preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = "Minutes".localized()
            }

            let saveAction = UIAlertAction(title: "Save".localized(), style: .default) { [weak alertController] (_) in
                let textField = alertController?.textFields![0]
                self.defaults.set(Int(textField?.text ?? "0"), forKey: "candleLightingOffset")
                self.tableView.reloadData()
            }
            alertController.addAction(saveAction)

            present(alertController, animated: true, completion: nil)
        }
        
        if indexPath.row == tekufaRow {
            let alertController = UIAlertController(title: "Tekufa Opinion".localized(), message:"Choose which opinion to use for the time for the tekufas".localized(), preferredStyle: .alert)

            let regularAction = UIAlertAction(title: "12PM start time (Ohr Hachaim)".localized(), style: .default) { (_) in
                self.defaults.set(1, forKey: "tekufaOpinion")
            }
            alertController.addAction(regularAction)
            
            let ahAction = UIAlertAction(title: "11:39AM start time (Amudei Horaah)".localized(), style: .default) { (_) in
                self.defaults.set(2, forKey: "tekufaOpinion")
            }
            alertController.addAction(ahAction)
            
            let bothAction = UIAlertAction(title: "Show Both".localized(), style: .default) { (_) in
                self.defaults.set(3, forKey: "tekufaOpinion")
            }
            alertController.addAction(bothAction)

            present(alertController, animated: true, completion: nil)
        }
        
        if indexPath.row == minutesForShabbatEndRow {
            let alertController = UIAlertController(title: "Shabbat/Chag End time".localized(), message:"Set how many minutes after sunset for shabbat/chag to end".localized(), preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = "Minutes".localized()
            }

            let saveAction = UIAlertAction(title: "Save".localized(), style: .default) { [weak alertController] (_) in
                let textField = alertController?.textFields![0]
                self.defaults.set(Int(textField?.text ?? "0"), forKey: "shabbatOffset")
                self.tableView.reloadData()
            }
            alertController.addAction(saveAction)

            if defaults.bool(forKey: "overrideAHEndShabbatTime") {
                present(alertController, animated: true, completion: nil)
            }
        }
        
        if indexPath.row == endShabbatOpinionRow {
            let alertController = UIAlertController(title: "Shabbat/Chag End Opinion".localized(), message:"Choose which opinion to use for the end of shabbat/chag".localized(), preferredStyle: .alert)

            let regularAction = UIAlertAction(title: "Regular Minutes".localized(), style: .default) { (_) in
                self.defaults.set(1, forKey: "endOfShabbatOpinion")
            }
            alertController.addAction(regularAction)
            
            let degreeAction = UIAlertAction(title: "7.165 Degrees".localized(), style: .default) { (_) in
                self.defaults.set(2, forKey: "endOfShabbatOpinion")
            }
            alertController.addAction(degreeAction)
            
            let lesserAction = UIAlertAction(title: "Lesser of the two".localized(), style: .default) { (_) in
                self.defaults.set(3, forKey: "endOfShabbatOpinion")
            }
            alertController.addAction(lesserAction)
            if defaults.bool(forKey: "overrideAHEndShabbatTime") {
                present(alertController, animated: true, completion: nil)
            }
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
