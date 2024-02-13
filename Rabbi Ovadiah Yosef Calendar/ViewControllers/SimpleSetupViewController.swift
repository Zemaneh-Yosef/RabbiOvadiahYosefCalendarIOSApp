//
//  SimpleSetupViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 8/15/23.
//

import UIKit
import KosherSwift

class SimpleSetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var metroArea: UITextField!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    
    @IBAction func download(_ sender: UIButton) {
        let presentingViewController = super.presentingViewController
        
        if chaitables.selectedCountry == "" || chaitables.selectedMetropolitanArea == "" {
            self.downloadButton.setTitle("Error, did you choose the right location?".localized(), for: .normal)
            self.downloadButton.setTitleColor(.white, for: .normal)
            self.downloadButton.tintColor = .red
            return
        }
        
        let link = chaitables.getChaiTablesLink(
            lat: GlobalStruct.geoLocation.latitude,
            long: GlobalStruct.geoLocation.longitude,
            timezone: -5,
            searchRadius: 8,
            type: 0,
            year: JewishCalendar().getJewishYear(),
            userId: 10000)
        
        let linkYr2 = chaitables.getChaiTablesLink(
            lat: GlobalStruct.geoLocation.latitude,
            long: GlobalStruct.geoLocation.longitude,
            timezone: -5,
            searchRadius: 8,
            type: 0,
            year: JewishCalendar().getJewishYear() + 1,
            userId: 10000)
                
        let scraper = ChaiTablesScraper(link: link,
                                        locationName: GlobalStruct.geoLocation.locationName,
                                        jewishYear: JewishCalendar().getJewishYear(),
                                        defaults: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
)
        scraper.scrape() {
            if scraper.errored {
                self.downloadButton.setTitle("Error, did you choose the right location?".localized(), for: .normal)
                self.downloadButton.setTitleColor(.white, for: .normal)
                self.downloadButton.tintColor = .red
            } else {
                scraper.jewishYear = scraper.jewishYear + 1
                scraper.link = linkYr2
                scraper.scrape {} // we do not care if there is an error since the first year was succesful
                super.dismiss(animated: false) {
                    presentingViewController?.dismiss(animated: false)
                }
            }
        }
    }
    
    var countryPickerView = UIPickerView()
    var statePickerView = UIPickerView()
    var metroPickerView = UIPickerView()
    
    let chaitables = ChaiTablesLinkGenerator()
    var countries = ChaiTablesCountries.allCases
    var states = Array<String>()
    var metros = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            downloadButton.configuration = .filled()
            downloadButton.tintColor = .init(named: "Gold")
            downloadButton.setTitleColor(.black, for: .normal)
        }
                
        locationName.text = GlobalStruct.geoLocation.locationName
        
        country.inputView = countryPickerView
        state.inputView = statePickerView
        metroArea.inputView = metroPickerView
        
        country.placeholder = "Select Country".localized()
        state.placeholder = "Select State".localized()
        metroArea.placeholder = "Select Metro Area".localized()
        
        country.textAlignment = .center
        state.textAlignment = .center
        metroArea.textAlignment = .center
        
        country.tintColor = .clear
        state.tintColor = .clear
        metroArea.tintColor = .clear
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        countryPickerView.tag = 1
        statePickerView.delegate = self
        statePickerView.dataSource = self
        statePickerView.tag = 2
        metroPickerView.delegate = self
        metroPickerView.dataSource = self
        metroPickerView.tag = 3
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return countries.count
        case 2:
            return states.count
        case 3:
            return metros.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return countries[row].label
        case 2:
            return states[row]
        case 3:
            return metros[row]
        default:
            return "----------"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        downloadButton.setTitle("Download".localized(), for: .normal)
        downloadButton.tintColor = .init(named: "Gold")
        downloadButton.setTitleColor(.black, for: .normal)
        switch pickerView.tag {
        case 1:
            if countries.isEmpty {
                return
            }
            country.text = countries[row].label
            state.text = ""
            metroArea.text = ""
            metros = chaitables.selectCountry(country: ChaiTablesCountries(rawValue: countries[row].rawValue)!)
            if countries[row] == ChaiTablesCountries.USA {
                state.isHidden = false
                for area in metros {
                    let state = String(area.suffix(2))
                    if !states.contains(state) {
                        states.append(state)
                    }
                    states.sort()
                }
            } else {
                state.isHidden = true
            }
            country.resignFirstResponder()
        case 2:
            if states.isEmpty {
                return
            }
            state.text = states[row]
            metroArea.text = ""
            let temp = ChaiTablesLinkGenerator().selectCountry(country: ChaiTablesCountries.USA)
            metros = []
            for area in temp {
                if area.contains(states[row]) {
                    metros.append(area)
                }
            }
            state.resignFirstResponder()
        case 3:
            if metros.isEmpty {
                return
            }
            metroArea.text = metros[row]
            chaitables.selectMetropolitanArea(metropolitanArea: metros[row])
            metroArea.resignFirstResponder()
        default:
            return
        }
    }
}
