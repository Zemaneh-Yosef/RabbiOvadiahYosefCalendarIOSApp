//
//  ZmanimSettingsViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/28/23.
//

import UIKit

class ZmanimSettingsViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    let candleLightingRow = 2
    let minutesForShabbatEndRow = 4
    let endShabbatOpinionRow = 5

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
        return 6
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicSettingsCell", for: indexPath)
        cell.accessoryView = nil

        var content = cell.defaultContentConfiguration()
        switch indexPath.row {
        case 0:
            content.text = "Luach Amudei Horaah"
            content.secondaryText = "Make the zmanim like the Luach Amudei Horaah (Only use outside of Israel)"
            let switchView = SwitchWithParam(frame: .zero)
            switchView.isOn = defaults.bool(forKey: "LuachAmudeiHoraah")
            switchView.param = "LuachAmudeiHoraah"
            switchView.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        case 1:
            content.text = "Tekufa Opinion"
            content.secondaryText = "Choose which opinion to use for the time for the tekufas"
        case candleLightingRow:
            content.text = "Candle Lighting Time"
            content.secondaryText = "Enter the amount of minutes for candle lighting"
        case 3:
            content.text = "The settings below only apply if you do not use the Luach Amudei Horaah setting above"
            content.secondaryText = ""
            content.textProperties.color = .systemBlue
            content.textProperties.alignment = .center
        case minutesForShabbatEndRow:
            content.text = "Minutes till shabbat ends"
            content.secondaryText = "Enter the amount of minutes to add to sunset for shabbat/chag to end"
        case endShabbatOpinionRow:
            content.text = "End shabbat opinion"
            content.secondaryText = "Choose which opinion to use for the time for when shabbat/chag ends"
        default:
            break
        }

        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == candleLightingRow {
            let alertController = UIAlertController(title: "Candle lighting time", message:"Set how many minutes before sunset is candle lighting", preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = "Minutes"
            }

            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak alertController] (_) in
                let textField = alertController?.textFields![0]
                self.defaults.set(Int(textField?.text ?? "0"), forKey: "candleLightingOffset")
                self.tableView.reloadData()
            }
            alertController.addAction(saveAction)

            present(alertController, animated: true, completion: nil)
        }
        
        if indexPath.row == 1 {
            let alertController = UIAlertController(title: "Tekufa Opinion", message:"Choose which opinion to use for the time for the tekufas", preferredStyle: .alert)

            let regularAction = UIAlertAction(title: "Regular 6PM start time (Ohr Hachaim)", style: .default) { (_) in
                self.defaults.set(1, forKey: "tekufaOpinion")
            }
            alertController.addAction(regularAction)
            
            let degreeAction = UIAlertAction(title: "11:39AM start time (Amudei Horaah)", style: .default) { (_) in
                self.defaults.set(2, forKey: "tekufaOpinion")
            }
            alertController.addAction(degreeAction)
            
            let lesserAction = UIAlertAction(title: "Show Both", style: .default) { (_) in
                self.defaults.set(3, forKey: "tekufaOpinion")
            }
            alertController.addAction(lesserAction)

            present(alertController, animated: true, completion: nil)
        }
        
        if indexPath.row == minutesForShabbatEndRow {
            let alertController = UIAlertController(title: "Shabbat/Chag End time", message:"Set how many minutes after sunset for shabbat/chag to end", preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = "Minutes"
            }

            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak alertController] (_) in
                let textField = alertController?.textFields![0]
                self.defaults.set(Int(textField?.text ?? "0"), forKey: "shabbatOffset")
                self.tableView.reloadData()
            }
            alertController.addAction(saveAction)

            present(alertController, animated: true, completion: nil)
        }
        
        if indexPath.row == endShabbatOpinionRow {
            let alertController = UIAlertController(title: "Shabbat/Chag End Opinion", message:"Choose which opinion to use for the end of shabbat/chag", preferredStyle: .alert)

            let regularAction = UIAlertAction(title: "Regular Minutes", style: .default) { (_) in
                self.defaults.set(1, forKey: "endOfShabbatOpinion")
            }
            alertController.addAction(regularAction)
            
            let degreeAction = UIAlertAction(title: "7.14 Degrees", style: .default) { (_) in
                self.defaults.set(2, forKey: "endOfShabbatOpinion")
            }
            alertController.addAction(degreeAction)
            
            let lesserAction = UIAlertAction(title: "Lesser of the two", style: .default) { (_) in
                self.defaults.set(3, forKey: "endOfShabbatOpinion")
            }
            alertController.addAction(lesserAction)

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
