//
//  LimudimViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 9/18/24.
//

import UIKit
import SwiftyJSON
import KosherSwift

class LimudimViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func prevDay(_ sender: UIButton) {
        GlobalStruct.userChosenDate = GlobalStruct.userChosenDate.advanced(by: -86400)
        GlobalStruct.jewishCalendar.workingDate = GlobalStruct.userChosenDate
        refreshTable()
    }
    @IBAction func calendarButton(_ sender: UIButton) {
        showDatePicker()
    }
    @IBAction func nextDay(_ sender: UIButton) {
        GlobalStruct.userChosenDate = GlobalStruct.userChosenDate.advanced(by: 86400)
        GlobalStruct.jewishCalendar.workingDate = GlobalStruct.userChosenDate
        refreshTable()
    }
    @IBOutlet weak var limudTableView: UITableView!
    var limudim = Array<ZmanListEntry>()
    var hiloulot = Array<ZmanListEntry>()
    var headDate = "";

    func numberOfSections(in tableView: UITableView) -> Int {3}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return limudim.count
        } else {
            return hiloulot.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let hiddenHeadCell = UIView()
            hiddenHeadCell.isHidden = true
            return hiddenHeadCell
        }

        let headerCell = UITableViewCell()
        var content = headerCell.defaultContentConfiguration()
        content.textProperties.adjustsFontSizeToFitWidth = true
        content.textProperties.numberOfLines = 1
        headerCell.backgroundColor = .secondarySystemBackground

        content.textProperties.alignment = .center

        if section == 1 {
            content.text = "Limudim".localized()
            headerCell.accessoryView = UIImageView(image: UIImage(systemName: "book"))
        } else {
            content.text = "Hillulot".localized()
            headerCell.accessoryView = UIImageView(image: UIImage(systemName: "flame"))
        }

        headerCell.contentConfiguration = content
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0
        }

        return tableView.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LimudEntry", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.textProperties.adjustsFontSizeToFitWidth = true
        content.textProperties.numberOfLines = 1

        content.textProperties.alignment = .center

        if indexPath.section != 0 {
            cell.accessoryView = .none
            cell.backgroundColor = .tertiarySystemGroupedBackground

            let limud = if indexPath.section == 1 { limudim[indexPath.row] } else { hiloulot[indexPath.row] }
            content.text = limud.title
            if !limud.src.isEmpty {
                content.textProperties.font = .systemFont(ofSize: 20, weight: .bold)
            }
        } else {
            content.text = headDate
        }

        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        }
        
        if indexPath.section == 1 {
            if limudim[indexPath.row].title.contains("Daf Yomi: ".localized()) {
                let masechta = YomiCalculator.getDafYomiBavli(jewishCalendar: GlobalStruct.jewishCalendar)!.getMasechtaTransliterated()
                let daf = YomiCalculator.getDafYomiBavli(jewishCalendar: GlobalStruct.jewishCalendar)!.getDaf()
                let dafYomiLink = "https://www.sefaria.org/"
                    .appending(masechta)
                    .appending(".")
                    .appending(String(daf))
                    .appending("a")
                alertController.title = "Open Sefaria Link for: ".localized()
                    .appending(limudim[indexPath.row].title
                    .replacingOccurrences(of: "Daf Yomi: ".localized(), with: "")
                    .appending("?"))
                alertController.message = "This will open the Sefaria website or app in a new window with the page.".localized()
                let okayAction = UIAlertAction(title: "OK".localized(), style: .default) { (_) in
                    if let url = URL(string: dafYomiLink) {
                            UIApplication.shared.open(url)
                    }
                }
                let dismissAction = UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in }
                alertController.addAction(okayAction)
                alertController.addAction(dismissAction)
                present(alertController, animated: true)
            } else if limudim[indexPath.row].title.contains("Yerushalmi Vilna Yomi: ".localized()) {
                let dafYomiYerushalmi = YerushalmiYomiCalculator.getDafYomiYerushalmi(jewishCalendar: GlobalStruct.jewishCalendar)
                let masechtotYerushalmiTransliterated = ["Berakhot", "Peah", "Demai", "Kilayim", "Sheviit",
                                                         "Terumot", "Maasrot", "Maaser Sheni", "Challah", "Orlah", "Bikkurim", "Shabbat", "Eruvin", "Pesachim",
                                                         "Beitzah", "Rosh Hashanah", "Yoma", "Sukkah", "Taanit", "Shekalim", "Megillah", "Chagigah", "Moed Katan",
                                                         "Yevamot", "Ketubot", "Sotah", "Nedarim", "Nazir", "Gittin", "Kiddushin", "Bava Kamma", "Bava Metzia",
                                                         "Bava Batra", "Shevuot", "Makkot", "Sanhedrin", "Avodah Zarah", "Horayot", "Niddah", "No Daf Today"]
                dafYomiYerushalmi?.setYerushalmiMasechtaTransliterated(masechtosYerushalmiTransliterated: masechtotYerushalmiTransliterated)
                let yerushalmiYomiLink = "https://www.sefaria.org/" + "Jerusalem_Talmud_" + (dafYomiYerushalmi?.getYerushalmiMasechtaTransliterated() ?? "")
                alertController.title = "Open Sefaria Link for: ".localized()
                    .appending(limudim[indexPath.row].title
                    .replacingOccurrences(of: "Yerushalmi Vilna Yomi: ".localized(), with: "")
                    .appending("?"))
                alertController.message = "This will open the Sefaria website or app in a new window with the page.".localized()
                let okayAction = UIAlertAction(title: "OK".localized(), style: .default) { (_) in
                    if let url = URL(string: yerushalmiYomiLink) {
                            UIApplication.shared.open(url)
                    }
                }
                let dismissAction = UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in }
                alertController.addAction(okayAction)
                alertController.addAction(dismissAction)
                present(alertController, animated: true)
            } else if limudim[indexPath.row].title.contains("Mishna Yomi: ".localized()) {
                let mishnaYomi = MishnaYomi.getMishnaYomi(jewishCalendar: GlobalStruct.jewishCalendar, useHebrewText: false)
                if mishnaYomi != nil {
                    let mishnaYomiLink = "https://www.sefaria.org/" + "Mishnah_" + mishnaYomi!
                    alertController.title = "Open Sefaria Link for: ".localized()
                        .appending(limudim[indexPath.row].title
                        .replacingOccurrences(of: "Mishna Yomi: ".localized(), with: "")
                        .appending("?"))
                    alertController.message = "This will open the Sefaria website or app in a new window with the page.".localized()
                    let okayAction = UIAlertAction(title: "OK".localized(), style: .default) { (_) in
                        if let url = URL(string: mishnaYomiLink) {
                                UIApplication.shared.open(url)
                        }
                    }
                    let dismissAction = UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in }
                    alertController.addAction(okayAction)
                    alertController.addAction(dismissAction)
                    present(alertController, animated: true)
                }
            }
        } else if indexPath.section == 2 && !hiloulot[indexPath.row].src.isEmpty {
            alertController.title = hiloulot[indexPath.row].title
            alertController.message = hiloulot[indexPath.row].src
            let dismissAction = UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in }
            alertController.addAction(dismissAction)
            present(alertController, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        limudTableView.dataSource = self
        limudTableView.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableWithNewDate), for: .valueChanged)
        limudTableView.refreshControl = refreshControl
        refreshTable()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTable()
    }

    @objc func refreshTableWithNewDate() {
        GlobalStruct.userChosenDate = Date()
        GlobalStruct.jewishCalendar.workingDate = GlobalStruct.userChosenDate
        refreshTable()
    }

    func refreshTable() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, yyyy"
        dateFormatter.timeZone = GlobalStruct.geoLocation.timeZone
        var date = dateFormatter.string(from: GlobalStruct.userChosenDate)

        let hDateFormatter = DateFormatter()
        hDateFormatter.calendar = Calendar(identifier: .hebrew)
        hDateFormatter.dateFormat = "d MMMM, yyyy"
        var hebrewDate = hDateFormatter.string(from: GlobalStruct.jewishCalendar.workingDate)
            .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
            .replacingOccurrences(of: "Tamuz", with: "Tammuz")

        if Locale.isHebrewLocale() {
            let hebrewDateFormatter = HebrewDateFormatter()
            hebrewDateFormatter.hebrewFormat = true
            hebrewDate = hebrewDateFormatter.format(jewishCalendar: GlobalStruct.jewishCalendar)
        }
        
        if Calendar.current.isDateInToday(GlobalStruct.userChosenDate) {
            date += "   ▼   " + hebrewDate
        } else {
            date += "       " + hebrewDate
        }
        headDate = date
//        limudim.append(ZmanListEntry(title:date))
//        limudim.append(ZmanListEntry(title: "Limudim".localized()))
        let hebrewDateFormatter = HebrewDateFormatter()
        hebrewDateFormatter.hebrewFormat = true
        hebrewDateFormatter.useGershGershayim = false
        
        limudim = []
        let dafYomi = GlobalStruct.jewishCalendar.getDafYomiBavli()
        if dafYomi != nil {
            limudim.append(ZmanListEntry(title:"Daf Yomi: ".localized() + hebrewDateFormatter.formatDafYomiBavli(daf: dafYomi!)))
        }
        let yerushalmiYomi = YerushalmiYomiCalculator.getDafYomiYerushalmi(jewishCalendar: GlobalStruct.jewishCalendar)
        if yerushalmiYomi != nil {
            limudim.append(ZmanListEntry(title:"Yerushalmi Vilna Yomi: ".localized() + hebrewDateFormatter.formatDafYomiYerushalmi(daf: yerushalmiYomi)))
        } else {
            limudim.append(ZmanListEntry(title:"No Yerushalmi Vilna Yomi".localized()))
        }
        let mishnaYomi = MishnaYomi.getMishnaYomi(jewishCalendar: GlobalStruct.jewishCalendar, useHebrewText: true)
        if mishnaYomi != nil {
            limudim.append(ZmanListEntry(title: "Mishna Yomi: ".localized() + (mishnaYomi ?? "")))
        }
        limudim.append(ZmanListEntry(title: "Daily Chafetz Chaim: ".localized() + ChafetzChayimYomi.getChafetzChayimYomi(jewishCalendar: GlobalStruct.jewishCalendar)))
        var dailyMonthlyTehilim: Array<String>
        if (Locale.isHebrewLocale()) {
                    dailyMonthlyTehilim = [
                            "א - ט",       // 1 - 9
                            "י - יז",      // 10 - 17
                            "יח - כב",     // 18 - 22
                            "כג - כח",     // 23 - 28
                            "כט - לד",     // 29 - 34
                            "לה - לח",     // 35 - 38
                            "לט - מג",     // 39 - 43
                            "מד - מח",     // 44 - 48
                            "מט - נד",     // 49 - 54
                            "נה - נט",     // 55 - 59
                            "ס - סה",      // 60 - 65
                            "סו - סח",     // 66 - 68
                            "סט - עא",     // 69 - 71
                            "עב - עו",     // 72 - 76
                            "עז - עח",     // 77 - 78
                            "עט - פב",     // 79 - 82
                            "פג - פז",     // 83 - 87
                            "פח - פט",     // 88 - 89
                            "צ - צו",      // 90 - 96
                            "צז - קג",     // 97 - 103
                            "קד - קה",     // 104 - 105
                            "קו - קז",     // 106 - 107
                            "קח - קיב",    // 108 - 112
                            "קיג - קיח",   // 113 - 118
                            "קיט:א - קיט:צו", // 119:1 - 119:96
                            "קיט:צז - קיט:קעו", // 119:97 - 119:176
                            "קכ - קלד",     // 120 - 134
                            "קל - קלט",     // 135 - 139
                            "קמ - " + (GlobalStruct.jewishCalendar.getDaysInJewishMonth() == 29 ? "קנ" : "קמה"), // 140 - 150 or 145
                            "קמה - קנ"       // 145 - 150
                    ]
                } else {
                    dailyMonthlyTehilim = [
                            "1 - 9",
                            "10 - 17",
                            "18 - 22",
                            "23 - 28",
                            "29 - 34",
                            "35 - 38",
                            "39 - 43",
                            "44 - 48",
                            "49 - 54",
                            "55 - 59",
                            "60 - 65",
                            "66 - 68",
                            "69 - 71",
                            "72 - 76",
                            "77 - 78",
                            "79 - 82",
                            "83 - 87",
                            "88 - 89",
                            "90 - 96",
                            "97 - 103",
                            "104 - 105",
                            "106 - 107",
                            "108 - 112",
                            "113 - 118",
                            "119:1 - 119:96",
                            "119:97 - 119:176",
                            "120 - 134",
                            "135 - 139",
                            "140 - " + (GlobalStruct.jewishCalendar.getDaysInJewishMonth() == 29 ? String(150) : String(145)),
                            "145 - 150"]
                }
        limudim.append(ZmanListEntry(title: "Daily Tehilim ".localized() + "(Monthly)".localized() + ": " + dailyMonthlyTehilim[GlobalStruct.jewishCalendar.getJewishDayOfMonth() - 1]))

        var dailyWeeklyTehilim: Array<String>
        if (Locale.isHebrewLocale()) {
            dailyWeeklyTehilim = [
                    "א - כט",      // 1 - 29
                    "ל - נ",       // 30 - 50
                    "נא - עב",     // 51 - 72
                    "עג - פט",     // 73 - 89
                    "צ - קו",      // 90 - 106
                    "קז - קיט",    // 107 - 119
                    "קכ - קנ"      // 120 - 150
            ]
        } else {
            dailyWeeklyTehilim = [
                    "1 - 29",
                    "30 - 50",
                    "51 - 72",
                    "73 - 89",
                    "90 - 106",
                    "107 - 119",
                    "120 - 150"
            ]
        }
        limudim.append(ZmanListEntry(title: "Daily Tehilim ".localized() + "(Weekly)".localized() + ": " + dailyWeeklyTehilim[GlobalStruct.jewishCalendar.getDayOfWeek() - 1]))
        
        
        //limudim.append(ZmanListEntry(title: "Hillulot".localized()))
        loadJsonFromFile(fileName: Locale.isHebrewLocale() ? "hiloulah_he" : "hiloulah_en")
        limudTableView.reloadData()
        limudTableView.refreshControl?.endRefreshing()
    }
    
    // Method to load JSON from the file and decode it into a Swift object
    func loadJsonFromFile(fileName:String) {
        // Get the file path for the JSON file
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                // Read the JSON file as Data
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                
                // Parse the data using SwiftyJSON
                let json = try JSON(data: data)
                
                let month = GlobalStruct.jewishCalendar.getNissanStartingJewishMonth()
                let day = GlobalStruct.jewishCalendar.getJewishDayOfMonth()
                var currentDate:String
                if month <= 9 {
                    currentDate = "0" + String(month)
                } else {
                    currentDate = String(month)
                }
                if day <= 9 {
                    currentDate += "0" + String(day)
                } else {
                    currentDate += String(day)
                }
                // Retrieve the array from the JSON for the currentDate
                if let currentHillulot = json[currentDate].array {
                    var hillulot: [ZmanListEntry] = []

                    // Loop through the array of hillulot
                    for hillula in currentHillulot {
                        var entry = ZmanListEntry(title: "")
                        if let name = hillula["name"].string {
                            entry.title = name
                        }

                        if let src = hillula["src"].string, !src.isEmpty, src != "-" {
                            entry.src = src
                        }
                        hillulot.append(entry)
                    }
                    hiloulot = hillulot
                }
            } catch {
                print("Error reading or parsing the hillulot JSON file: \(error)")
            }
        }
    }
    
    @objc func showDatePicker() {
        var alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Select a date".localized(), message: nil, preferredStyle: .alert)
        }

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = GlobalStruct.userChosenDate
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
            self.refreshTable()
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
        datePicker.date = GlobalStruct.userChosenDate
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
            self.refreshTable()
        }

        alertController.addAction(doneAction)

        present(alertController, animated: true, completion: nil)
    }

    // Function to handle changes to the date picker value
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        GlobalStruct.userChosenDate = sender.date
        GlobalStruct.jewishCalendar.workingDate = GlobalStruct.userChosenDate
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

struct Limud: Codable {
    let name: String
    let src: String
}
