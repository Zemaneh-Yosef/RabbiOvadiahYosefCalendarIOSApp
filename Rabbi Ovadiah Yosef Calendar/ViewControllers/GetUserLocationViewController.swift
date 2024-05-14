//
//  GetUserLocationViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/12/24.
//

import UIKit
import MapKit
import SnackBar

class GetUserLocationViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var locationName: String = ""
    var lat: Double = 0
    var long: Double = 0
    var timezone: TimeZone = TimeZone.current.corrected()
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var chosenLocationAnnotation = MKPointAnnotation()
    var searchResults: [MKMapItem] = []
    var localSearch: MKLocalSearch?
    
    var useZipcode = false
    var useAdvanced = false
    var useLocation1 = false
    var useLocation2 = false
    var useLocation3 = false
    var useLocation4 = false
    var useLocation5 = false
    var bLocationName = ""
    var bLat = 0.0
    var bLong = 0.0
    var bTimezone = TimeZone.current.corrected()
    var bALocationName = ""
    var bALat = 0.0
    var bALong = 0.0
    var bATimezone = TimeZone.current.corrected()
    
    @IBOutlet weak var tableview: UITableView!
    @IBAction func back(_ sender: UIButton) {
        defaults.set(useZipcode, forKey: "useZipcode")
        defaults.set(useAdvanced, forKey: "useAdvanced")
        defaults.set(bLocationName, forKey: "locationName")
        defaults.set(bLat, forKey: "lat")
        defaults.set(bLong, forKey: "long")
        defaults.set(bTimezone.identifier, forKey: "timezone")
        defaults.setValue(bALocationName, forKey: "advancedLN")
        defaults.setValue(bALat, forKey: "advancedLat")
        defaults.setValue(bALong, forKey: "advancedLong")
        defaults.setValue(bATimezone.identifier, forKey: "advancedTimezone")
        useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
        useLocation(location1: useLocation1, location2: useLocation2, location3: useLocation3, location4: useLocation4, location5: useLocation5)
        super.dismiss(animated: true)
    }
    @IBAction func advanced(_ sender: UIButton) {
        let advancedAlert = UIAlertController(title: "Advanced".localized(),
                                              message: "Enter your location's name, latitude, longitude, elevation, and timezone.".localized(), preferredStyle: .alert)
        advancedAlert.addTextField { (textField) in
            textField.placeholder = "ex: New York"
        }
        advancedAlert.addTextField { (textField) in
            textField.placeholder = "ex: 73.09876543"
        }
        advancedAlert.addTextField { (textField) in
            textField.placeholder = "ex: -103.098765"
        }
        advancedAlert.addTextField { (textField) in
            textField.placeholder = "ex: 805"
        }
        advancedAlert.addTextField { (textField) in
            textField.placeholder = "Timezone e.g. America/New_York"
        }
        advancedAlert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { [self] UIAlertAction in
            map.removeAnnotation(chosenLocationAnnotation)
            defaults.setValue(true, forKey: "useAdvanced")
            defaults.setValue(false, forKey: "useZipcode")
            useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
            
            locationName = advancedAlert.textFields![0].text ?? ""
            lat = Double(advancedAlert.textFields![1].text ?? "") ?? 0
            long = Double(advancedAlert.textFields![2].text ?? "") ?? 0
            let elevation = Double(advancedAlert.textFields![3].text ?? "")
            let timezone = advancedAlert.textFields![4].text

            if timezone == nil { // don't do anything if the timezone was never filled in
                return
            } else {
                defaults.setValue(locationName, forKey: "advancedLN")
                defaults.setValue(lat, forKey: "advancedLat")
                defaults.setValue(long, forKey: "advancedLong")
                defaults.setValue(elevation, forKey: "elevation".appending(locationName))
                defaults.setValue(timezone, forKey: "advancedTimezone")
            }
            zoomMapToPlaceAndAddAnnotation()
        }))
        advancedAlert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { UIAlertAction in
            advancedAlert.dismiss(animated: true)
        }))
        self.present(advancedAlert, animated: true)
    }
    @IBAction func useLocation(_ sender: UIButton) {
        map.removeAnnotation(chosenLocationAnnotation)
        LocationManager.shared.getUserLocation {
            location in DispatchQueue(label: "mainApp", attributes: .concurrent).async { [self] in
                lat = location.coordinate.latitude
                long = location.coordinate.longitude
                defaults.set(false, forKey: "useZipcode")
                defaults.set(false, forKey: "useAdvanced")
                useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                LocationManager.shared.resolveLocationName(with: location) { [self] locationName in
                    zoomMapToPlaceAndAddAnnotation()
                }
            }
        }
        GreenSnackBar.make(in: self.view, message: "The application will keep requesting your location".localized(), duration: .lengthShort).show()
    }
    @IBOutlet weak var search: UISearchBar!
    @IBAction func confirm(_ sender: Any) {
        if !defaults.bool(forKey: "isSetup") {// We got location before
            if !defaults.bool(forKey: "inIsrael") {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyboard.instantiateViewController(withIdentifier: "calendarChooser") as! CalendarViewController
                self.present(newViewController, animated: false)
            }
            defaults.setValue(true, forKey: "isSetup")
        } else {
            let inIsraelView = super.presentingViewController?.presentingViewController
            let zmanimLanguagesView = super.presentingViewController
            
            super.dismiss(animated: false) {//when this view is dismissed, dismiss the superview as well
                if zmanimLanguagesView != nil {
                    zmanimLanguagesView?.dismiss(animated: false) {
                        if inIsraelView != nil {
                            inIsraelView?.dismiss(animated: false)
                        }
                    }
                }
            }
        }
    }
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
        tableview.delegate = self
        tableview.dataSource = self
        lat = GlobalStruct.geoLocation.latitude
        long = GlobalStruct.geoLocation.longitude
        zoomMapToPlaceAndAddAnnotation()
        
        useZipcode = defaults.bool(forKey: "useZipcode")
        useAdvanced = defaults.bool(forKey: "useAdvanced")
        useLocation1 = defaults.bool(forKey: "useLocation1")
        useLocation2 = defaults.bool(forKey: "useLocation2")
        useLocation3 = defaults.bool(forKey: "useLocation3")
        useLocation4 = defaults.bool(forKey: "useLocation4")
        useLocation5 = defaults.bool(forKey: "useLocation5")
        bLocationName = defaults.string(forKey: "locationName") ?? ""
        bLat = defaults.double(forKey: "Lat")
        bLong = defaults.double(forKey: "Long")
        bTimezone = TimeZone(identifier: defaults.string(forKey: "timezone") ?? timezone.identifier) ?? timezone
        bALocationName = defaults.string(forKey: "advancedLN") ?? ""
        bALat = defaults.double(forKey: "advancedLat")
        bALong = defaults.double(forKey: "advancedLong")
        bATimezone = TimeZone(identifier: defaults.string(forKey: "advancedTimezone") ?? timezone.identifier) ?? timezone
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        map.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
        //This method is called when the user taps on the map view.
        map.removeAnnotation(chosenLocationAnnotation)
        let location = gestureRecognizer.location(in: map)
        let coordinate = map.convert(location, toCoordinateFrom: map)
        lat = coordinate.latitude
        long = coordinate.longitude
        LocationManager.shared.resolveLocationName(with: CLLocation(latitude: lat, longitude: long)) { [self] locationName in
            self.locationName = locationName ?? ""
            CLGeocoder().geocodeAddressString(self.locationName, in: nil, preferredLocale: .current, completionHandler: { [self] i, j in
                if i?.first?.timeZone != nil {
                    self.timezone = (i?.first?.timeZone)!
                }
                defaults.setValue(true, forKey: "useAdvanced")
                defaults.setValue(false, forKey: "useZipcode")
                useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                defaults.setValue(self.locationName, forKey: "advancedLN")
                defaults.setValue(lat, forKey: "advancedLat")
                defaults.setValue(long, forKey: "advancedLong")
                defaults.setValue(timezone.identifier, forKey: "advancedTimezone")
                zoomMapToPlaceAndAddAnnotation()
            })
        }
        RedSnackBar.make(in: self.view, message: "The application will NOT track your location".localized(), duration: .lengthShort).show()

    }
    
    func zoomMapToPlaceAndAddAnnotation() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let regionSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: centerCoordinate, span: regionSpan)
        // Set the region on the map I.E. Zoom in
        map.setRegion(region, animated: true)
        chosenLocationAnnotation.coordinate = centerCoordinate
        chosenLocationAnnotation.title = locationName
        chosenLocationAnnotation.subtitle = timezone.identifier
        map.addAnnotation(chosenLocationAnnotation)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            tableview.isHidden = true
        } else {
            tableview.isHidden = false
            localSearch?.cancel()// Cancel any previous search
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            localSearch = MKLocalSearch(request: request)
            
            localSearch?.start { [weak self] (response, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Local search error:", error.localizedDescription)
                    return
                }
                
                if let response = response {
                    self.searchResults = response.mapItems
                    addSavedLocation(locationDefault: "location1")
                    addSavedLocation(locationDefault: "location2")
                    addSavedLocation(locationDefault: "location3")
                    addSavedLocation(locationDefault: "location4")
                    addSavedLocation(locationDefault: "location5")
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    func addSavedLocation(locationDefault:String) {
        let location = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: defaults.double(forKey: locationDefault.appending("Lat")), longitude: defaults.double(forKey: locationDefault.appending("Long")))))
        location.name = defaults.string(forKey: locationDefault)
        location.timeZone = TimeZone(identifier: locationDefault.appending("Timezone"))
        if let l = defaults.string(forKey: locationDefault) {
            if !l.isEmpty {
                searchResults.append(location)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var search = searchBar.text
        if search != nil {
            search = search!
        }
        if search!.isEmpty || search == nil {
            let alert = UIAlertController(title: "Error".localized(), message: "Please enter a valid zipcode or address.".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: {_ in
                alert.dismiss(animated: true)
            }))
            self.present(alert, animated: true)
        } else {// There is some input
            map.removeAnnotation(chosenLocationAnnotation)
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString((searchBar.text)!, in: nil, preferredLocale: .current, completionHandler: { i, j in
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
                    name = "No location name info".localized()
                }
                self.locationName = name
                let coordinates = i?.first?.location?.coordinate
                self.lat = coordinates?.latitude ?? 0
                self.long = coordinates?.longitude ?? 0
                if i?.first?.timeZone != nil {
                    self.timezone = (i?.first?.timeZone)!
                }
                self.defaults.set(name, forKey: "locationName")
                self.defaults.set(self.lat, forKey: "lat")
                self.defaults.set(self.long, forKey: "long")
                self.defaults.set(true, forKey: "useZipcode")
                self.defaults.set(false, forKey: "useAdvanced")
                self.useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                self.defaults.set(self.timezone.identifier, forKey: "timezone")
                self.saveLocation()
                self.tableview.isHidden = true
                self.zoomMapToPlaceAndAddAnnotation()
            })
        }
        searchBar.resignFirstResponder()
        RedSnackBar.make(in: self.view, message: "The application will NOT track your location".localized(), duration: .lengthShort).show()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionEntry", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.textProperties.adjustsFontSizeToFitWidth = true
        content.textProperties.numberOfLines = 1
        
        let selectedItem = searchResults[indexPath.row].placemark
        content.text = selectedItem.name
        let address = parseAddress(selectedItem: selectedItem)
        if !address.isEmpty {
            content.secondaryText = address
        }
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        map.removeAnnotation(chosenLocationAnnotation)
        let selectedItem = searchResults[indexPath.row]
        search.text = selectedItem.name
        search.resignFirstResponder()// Dismiss the keyboard
        
        locationName = selectedItem.name ?? "No location name info".localized()
        lat = selectedItem.placemark.coordinate.latitude
        long = selectedItem.placemark.coordinate.longitude
        CLGeocoder().geocodeAddressString(locationName, in: nil, preferredLocale: .current, completionHandler: { [self] i, j in
            if i?.first?.timeZone != nil {
                self.timezone = (i?.first?.timeZone)!
                if locationName == defaults.string(forKey: "location1") || locationName == defaults.string(forKey: "location2") || locationName == defaults.string(forKey: "location3") || locationName == defaults.string(forKey: "location4") || locationName == defaults.string(forKey: "location5") {
                    defaults.setValue(false, forKey: "useAdvanced")
                    defaults.setValue(false, forKey: "useZipcode")
                    useLocation(location1: locationName == defaults.string(forKey: "location1"),
                                location2: locationName == defaults.string(forKey: "location2"),
                                location3: locationName == defaults.string(forKey: "location3"),
                                location4: locationName == defaults.string(forKey: "location4"),
                                location5: locationName == defaults.string(forKey: "location5"))
                } else {
                    defaults.setValue(true, forKey: "useAdvanced")
                    defaults.setValue(false, forKey: "useZipcode")
                    useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                    defaults.setValue(locationName, forKey: "advancedLN")
                    defaults.setValue(lat, forKey: "advancedLat")
                    defaults.setValue(long, forKey: "advancedLong")
                    defaults.setValue(timezone.identifier, forKey: "advancedTimezone")
                    saveLocation()
                }
                tableView.isHidden = true
                zoomMapToPlaceAndAddAnnotation()
            }
        })
        RedSnackBar.make(in: self.view, message: "The application will NOT track your location".localized(), duration: .lengthShort).show()
    }
    
    func showZipcodeAlert() {
        let alert = UIAlertController(title: "Location or Search a place?".localized(),
                                      message: "You can choose to use your device's location, or you can search for a place below. It is recommended to use your devices location as this provides more accurate results and it will automatically update your location.".localized(), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Zipcode/Address".localized()
        }
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            //if text is empty, display a message notifying the user:
            if textField?.text == "" {
                let alert = UIAlertController(title: "Error".localized(), message: "Please enter a valid zipcode or address.".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: {_ in
                    self.showZipcodeAlert()
                }))
                self.present(alert, animated: true)
                return
            }
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString((textField?.text)!, in: nil, preferredLocale: .current, completionHandler: { i, j in
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
                    name = "No location name info".localized()
                }
                self.locationName = name
                let coordinates = i?.first?.location?.coordinate
                self.lat = coordinates?.latitude ?? 0
                self.long = coordinates?.longitude ?? 0
                if i?.first?.timeZone != nil {
                    self.timezone = (i?.first?.timeZone)!
                }
                self.defaults.set(name, forKey: "locationName")
                self.defaults.set(self.lat, forKey: "lat")
                self.defaults.set(self.long, forKey: "long")
                self.defaults.set(true, forKey: "useZipcode")
                self.defaults.set(false, forKey: "useAdvanced")
                self.useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                self.defaults.set(self.timezone.identifier, forKey: "timezone")
                self.saveLocation()
            })
        }))
        if defaults.string(forKey: "location1") ?? "" != "" {
            alert.addAction(UIAlertAction(title: defaults.string(forKey: "location1"), style: .default, handler: { UIAlertAction in
                self.useLocation(location1: true, location2: false, location3: false, location4: false, location5: false)
            }))
        }
        if defaults.string(forKey: "location2") ?? "" != "" {
            alert.addAction(UIAlertAction(title: defaults.string(forKey: "location2"), style: .default, handler: { UIAlertAction in
                self.useLocation(location1: false, location2: true, location3: false, location4: false, location5: false)
            }))
        }
        if defaults.string(forKey: "location3") ?? "" != "" {
            alert.addAction(UIAlertAction(title: defaults.string(forKey: "location3"), style: .default, handler: { UIAlertAction in
                self.useLocation(location1: false, location2: false, location3: true, location4: false, location5: false)
            }))
        }
        if defaults.string(forKey: "location4") ?? "" != "" {
            alert.addAction(UIAlertAction(title: defaults.string(forKey: "location4"), style: .default, handler: { UIAlertAction in
                self.useLocation(location1: false, location2: false, location3: false, location4: true, location5: false)
            }))
        }
        if defaults.string(forKey: "location5") ?? "" != "" {
            alert.addAction(UIAlertAction(title: defaults.string(forKey: "location5"), style: .default, handler: { UIAlertAction in
                self.useLocation(location1: false, location2: false, location3: false, location4: false, location5: true)
            }))
        }
        alert.addAction(UIAlertAction(title: "Use Location".localized(), style: .default, handler: { UIAlertAction in
            //self.getUserLocation()
        }))
        alert.addAction(UIAlertAction(title: "Advanced".localized(), style: .default, handler: { UIAlertAction in
            //self.present(advancedAlert, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { UIAlertAction in
            alert.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveLocation() {
        var setOfLocationNames = Set<String>()
        
        setOfLocationNames.insert(defaults.string(forKey: "location1") ?? "")
        setOfLocationNames.insert(defaults.string(forKey: "location2") ?? "")
        setOfLocationNames.insert(defaults.string(forKey: "location3") ?? "")
        setOfLocationNames.insert(defaults.string(forKey: "location4") ?? "")
        setOfLocationNames.insert(defaults.string(forKey: "location5") ?? "")
        
        if !locationName.isEmpty && !setOfLocationNames.contains(locationName) {
            defaults.setValue(defaults.string(forKey: "location4") ?? "", forKey: "location5")
            defaults.setValue(defaults.double(forKey: "location4Lat"), forKey: "location5Lat")
            defaults.setValue(defaults.double(forKey: "location4Long"), forKey: "location5Long")
            defaults.setValue(defaults.string(forKey: "location4Timezone"), forKey: "location5Timezone")
            
            defaults.setValue(defaults.string(forKey: "location3") ?? "", forKey: "location4")
            defaults.setValue(defaults.double(forKey: "location3Lat"), forKey: "location4Lat")
            defaults.setValue(defaults.double(forKey: "location3Long"), forKey: "location4Long")
            defaults.setValue(defaults.string(forKey: "location3Timezone"), forKey: "location4Timezone")
            
            defaults.setValue(defaults.string(forKey: "location2") ?? "", forKey: "location3")
            defaults.setValue(defaults.double(forKey: "location2Lat"), forKey: "location3Lat")
            defaults.setValue(defaults.double(forKey: "location2Long"), forKey: "location3Long")
            defaults.setValue(defaults.string(forKey: "location2Timezone"), forKey: "location3Timezone")

            defaults.setValue(defaults.string(forKey: "location1") ?? "", forKey: "location2")
            defaults.setValue(defaults.double(forKey: "location1Lat"), forKey: "location2Lat")
            defaults.setValue(defaults.double(forKey: "location1Long"), forKey: "location2Long")
            defaults.setValue(defaults.string(forKey: "location1Timezone"), forKey: "location2Timezone")

            defaults.setValue(locationName, forKey: "location1")
            defaults.setValue(lat, forKey: "location1Lat")
            defaults.setValue(long, forKey: "location1Long")
            defaults.setValue(timezone.identifier, forKey: "location1Timezone")
        }
    }
        
    func useLocation(location1:Bool, location2:Bool, location3:Bool, location4:Bool, location5:Bool) {
        defaults.setValue(location1, forKey: "useLocation1")
        defaults.setValue(location2, forKey: "useLocation2")
        defaults.setValue(location3, forKey: "useLocation3")
        defaults.setValue(location4, forKey: "useLocation4")
        defaults.setValue(location5, forKey: "useLocation5")
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}

class GreenSnackBar: SnackBar {
    
    override var style: SnackBarStyle {
        var style = SnackBarStyle()
        style.background = .systemGreen
        style.textColor = .black
        return style
    }
}

class RedSnackBar: SnackBar {
    
    override var style: SnackBarStyle {
        var style = SnackBarStyle()
        style.background = .red
        style.textColor = .white
        return style
    }
}
