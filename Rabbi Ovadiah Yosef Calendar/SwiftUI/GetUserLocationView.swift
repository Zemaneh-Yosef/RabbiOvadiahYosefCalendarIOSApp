//
//  GetUserLocationView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 4/6/25.
//

import SwiftUI
import MapKit
import SwiftUISnackbar

struct GetUserLocationView: View {
    public static var loneView: Bool = false

    var body: some View {
        if #available(iOS 17.0, *) {// SwiftUI Maps got a big update in iOS 17
            GetiOS17PlusUserLocationView()
        } else {
            GetiOS16MinusUserLocationView()
        }
    }
}

@available(iOS 17.0, *)
struct GetiOS17PlusUserLocationView: View {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    @State private var position: MapCameraPosition = .item(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude))))
    @State private var searchQuery = ""
    @FocusState private var searchFocused: Bool
    @State var searchResults: [MKMapItem] = []
    @State var localSearch: MKLocalSearch?

    @State var locationName: String = ""
    @State var lat: Double = 0
    @State var long: Double = 0
    @State var timezone: TimeZone = TimeZone.current
    
    @State var showNoLocationPermissionSnackbar = false
    @State var showNoLocationSetSnackbar = false
    @State var showRedSnackbar = false
    @State var showGreenSnackbar = false
    
    @State var useZipcode = false
    @State var useAdvanced = false
    @State var useLocation1 = false
    @State var useLocation2 = false
    @State var useLocation3 = false
    @State var useLocation4 = false
    @State var useLocation5 = false
    
    @State var bLocationName = ""
    @State var bLat = 0.0
    @State var bLong = 0.0
    @State var bTimezone = TimeZone.current.corrected()
    
    @State var bALocationName = ""
    @State var bALat = 0.0
    @State var bALong = 0.0
    @State var bATimezone = TimeZone.current.corrected()
    
    @State var showAdvancedAlert = false
    @State var AdvancedLocationName: String = ""
    @State var AdvancedLat: String = ""
    @State var AdvancedLong: String = ""
    @State var AdvancedElevation: String = ""
    @State var AdvancedTimezone: String = ""
    
    @State var confirmPressed = false
    @State var showEmptyError = false
    @Environment(\.dismiss) private var dismiss
    @State var nextView = NextSetupView.inIsrael

    var body: some View {
        VStack {
            TextField("Enter location name/ZIP code", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($searchFocused)
                .onChange(of: searchQuery) {
                    if searchQuery.count > 2 {
                        performSearch()
                    }
                }
                .onSubmit {
                    submitSearch()
                }
            Button {
                getDeviceLocation()
            } label: {
                Image(systemName: "location")
                Text("Use my device's location")
            }
            .tint(.blue)
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
            
            if !searchResults.isEmpty {
                List(searchResults, id: \.self) { item in
                    Button {
                        selectMapItem(item)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unknown")
                            Text(parseAddress(selectedItem: item.placemark))
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                .listStyle(.plain)
            }
            if searchResults.isEmpty {
                MapReader { reader in
                    Map(position: $position) {
                        Marker(coordinate: position.item?.placemark.coordinate ?? CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude)) {
                            Text(locationName)
                        }
                    }
                    .onTapGesture(perform: { screenCoord in
                        let location = reader.convert(screenCoord, from: .local)
                        
                        let coordinate = CLLocationCoordinate2D(latitude: location?.latitude ?? 0, longitude: location?.longitude ?? 0)
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
                                withAnimation {
                                    position = .item(MKMapItem(placemark: .init(coordinate: coordinate)))
                                }
                            })
                        }
                        showRedSnackbar = true
                    })
                }
                Button {
                    handleConfirm()
                } label: {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .background {
            NavigationLink("", isActive: $confirmPressed) {
                switch nextView {
                case .inIsrael:
                    InIsraelView().applyToolbarHidden()
                case .zmanimLanguage:
                    ZmanimLanguageView().applyToolbarHidden()
                case .tipScreen:
                    TipScreenView().applyToolbarHidden()
                }
            }.hidden()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAdvancedAlert = true
                } label: {
                    Text("Advanced")
                }
            }
        }
        .navigationTitle("Search for a place")
        .snackbar(isShowing: $showNoLocationPermissionSnackbar, title: "No location permission".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.red))
        .snackbar(isShowing: $showNoLocationSetSnackbar, title: "No location set".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.red))
        .snackbar(isShowing: $showRedSnackbar, title: "The application will NOT track your location".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.red))
        .snackbar(isShowing: $showGreenSnackbar, title: "The application will keep requesting your location".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.green))
        .alert("Advanced", isPresented: $showAdvancedAlert) {
            TextField(text: $AdvancedLocationName, prompt: Text("ex: New York")) {}
            TextField(text: $AdvancedLat, prompt: Text("ex: 40.808058")) {}
            TextField(text: $AdvancedLong, prompt: Text("ex: -73.740559")) {}
            TextField(text: $AdvancedElevation, prompt: Text("ex: 30")) {}
            TextField(text: $AdvancedTimezone, prompt: Text("ex: America/New_York")) {}
            Button("OK") {
                defaults.setValue(true, forKey: "useAdvanced")
                defaults.setValue(false, forKey: "useZipcode")
                useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                
                locationName = AdvancedLocationName
                lat = Double(AdvancedLat) ?? 0
                long = Double(AdvancedLong) ?? 0
                let elevation = Double(AdvancedElevation)
                let timezone = AdvancedTimezone

                if timezone == "" { // don't do anything if the timezone was never filled in
                    return
                } else {
                    defaults.setValue(locationName, forKey: "advancedLN")
                    defaults.setValue(lat, forKey: "advancedLat")
                    defaults.setValue(long, forKey: "advancedLong")
                    defaults.setValue(elevation, forKey: "elevation".appending(locationName))
                    defaults.setValue(timezone, forKey: "advancedTimezone")
                }
                position = .item(MKMapItem(placemark: .init(coordinate: .init(latitude: lat, longitude: long))))
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your location's name, latitude, longitude, elevation, and timezone.")
        }
        .alert("Error", isPresented: $showEmptyError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a valid zipcode or address.")
        }
        .onChange(of: showAdvancedAlert) {
            AdvancedLocationName = ""
            AdvancedLat = ""
            AdvancedLong = ""
            AdvancedElevation = ""
            AdvancedTimezone = ""
        }
    }
    
    private func handleConfirm() {
        if lat == 0 && long == 0 {
            showNoLocationSetSnackbar = true
            return
        }
        if GetUserLocationView.loneView {
            dismiss()// this is good for one view
        } else {
            if timezone.corrected().identifier == "Asia/Jerusalem" {
                nextView = .inIsrael
                confirmPressed = true
            } else if !Locale.isHebrewLocale() {
                defaults.set(false, forKey: "inIsrael")
                defaults.set(true, forKey: "LuachAmudeiHoraah")
                defaults.set(false, forKey: "useElevation")
                nextView = .zmanimLanguage
                confirmPressed = true
            } else {
                defaults.set(false, forKey: "inIsrael")
                defaults.set(true, forKey: "LuachAmudeiHoraah")
                defaults.set(false, forKey: "useElevation")
                defaults.set(true, forKey: "isZmanimInHebrew")
                defaults.set(false, forKey: "isZmanimEnglishTranslated")
                defaults.set(true, forKey: "isSetup")
                if !defaults.bool(forKey: "hasShownTipScreen") {
                    nextView = .tipScreen
                    confirmPressed = true
                    defaults.set(true, forKey: "hasShownTipScreen")
                } else {
                    goBackToRootView()
                }
            }
        }
        GetUserLocationView.loneView = false// reset bool
    }
    
    private func goBackToRootView() {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
          return
        }
        guard let firstWindow = firstScene.windows.first else {
          return
        }
        firstWindow.rootViewController = UIHostingController(rootView: ContentView())
        firstWindow.makeKeyAndVisible()
    }
    
    private func getDeviceLocation() {
        searchResults.removeAll()
        searchQuery = ""
        searchFocused = false
        LocationManager.shared.getUserLocation {
            location in DispatchQueue(label: "mainApp", attributes: .concurrent).async { [self] in
                if location != nil {
                    showGreenSnackbar = true
                    lat = location!.coordinate.latitude
                    long = location!.coordinate.longitude
                    defaults.set(false, forKey: "useZipcode")
                    defaults.set(false, forKey: "useAdvanced")
                    useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                    LocationManager.shared.resolveLocationName(with: location!) { [self] locationName in
                        self.locationName = locationName ?? ""
                        position = .item(MKMapItem(placemark: .init(coordinate: location!.coordinate)))
                    }
                } else {
                    showNoLocationPermissionSnackbar = true
                }
            }
        }
    }
    
    private func submitSearch() {
        if searchQuery.isEmpty {
            showEmptyError = true
        } else {// There is some input
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(searchQuery, in: nil, preferredLocale: .current, completionHandler: { i, j in
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
                searchResults.removeAll()
                searchQuery = ""
                searchFocused = false
                position = .item(MKMapItem(placemark: .init(coordinate: .init(latitude: lat, longitude: long))))
            })
        }
        showRedSnackbar = true
    }

    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let items = response?.mapItems {
                self.searchResults = items
                addSavedLocation(locationDefault: "location1")
                addSavedLocation(locationDefault: "location2")
                addSavedLocation(locationDefault: "location3")
                addSavedLocation(locationDefault: "location4")
                addSavedLocation(locationDefault: "location5")
            }
        }
    }
    
    func addSavedLocation(locationDefault: String) {
        let location = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: defaults.double(forKey: locationDefault.appending("Lat")), longitude: defaults.double(forKey: locationDefault.appending("Long")))))
        location.name = defaults.string(forKey: locationDefault)
        location.timeZone = TimeZone(identifier: locationDefault.appending("Timezone"))
        if let l = defaults.string(forKey: locationDefault) {
            if !l.isEmpty {
                searchResults.append(location)
            }
        }
    }

    private func selectMapItem(_ item: MKMapItem) {
        guard let coordinate = item.placemark.location?.coordinate else { return }
        
        withAnimation {
            position = .item(MKMapItem(placemark: .init(coordinate: coordinate)))
        }
        
        locationName = item.name ?? "Selected Location"
        lat = coordinate.latitude
        long = coordinate.longitude
        timezone = item.timeZone ?? TimeZone.current.corrected()
        
        CLGeocoder().geocodeAddressString(locationName, in: nil, preferredLocale: .current, completionHandler: { [self] i, j in
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
            locationName = name
            if i?.first?.timeZone != nil {
                self.timezone = (i?.first?.timeZone)!
                if locationName == defaults.string(forKey: "location1") ||
                    locationName == defaults.string(forKey: "location2") ||
                    locationName == defaults.string(forKey: "location3") ||
                    locationName == defaults.string(forKey: "location4") ||
                    locationName == defaults.string(forKey: "location5") {
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
            }
        })
        showRedSnackbar = true
        
        searchResults.removeAll()
        searchQuery = ""
        searchFocused = false
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

// In order to get this to work, I removed the ability to click anywhere on the map to set your location and there is no location name under the map marker (adding a Text throws an error). There is also a small issue of the map marker always being shown even when the user is just moving the map, I am not going to stress about it because it will eventually be a non-issue.
struct GetiOS16MinusUserLocationView: View {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude,
                                       longitude: GlobalStruct.geoLocation.longitude),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    @State private var searchQuery = ""
    @FocusState private var searchFocused: Bool
    @State var searchResults: [MKMapItem] = []
    @State var localSearch: MKLocalSearch?

    @State var locationName: String = ""
    @State var lat: Double = 0
    @State var long: Double = 0
    @State var timezone: TimeZone = TimeZone.current
    
    @State var showNoLocationPermissionSnackbar = false
    @State var showNoLocationSetSnackbar = false
    @State var showRedSnackbar = false
    @State var showGreenSnackbar = false
    
    @State var useZipcode = false
    @State var useAdvanced = false
    @State var useLocation1 = false
    @State var useLocation2 = false
    @State var useLocation3 = false
    @State var useLocation4 = false
    @State var useLocation5 = false
    
    @State var bLocationName = ""
    @State var bLat = 0.0
    @State var bLong = 0.0
    @State var bTimezone = TimeZone.current.corrected()
    
    @State var bALocationName = ""
    @State var bALat = 0.0
    @State var bALong = 0.0
    @State var bATimezone = TimeZone.current.corrected()
    
    @State var showAdvancedAlert = false
    @State var AdvancedLocationName: String = ""
    @State var AdvancedLat: String = ""
    @State var AdvancedLong: String = ""
    @State var AdvancedElevation: String = ""
    @State var AdvancedTimezone: String = ""
    
    @State var confirmPressed = false
    @State var showEmptyError = false
    @Environment(\.dismiss) private var dismiss
    @State var nextView = NextSetupView.inIsrael
    
    struct LocationItem: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
    
    private var annotationItems: [LocationItem] {
        [LocationItem(coordinate: region.center)]
    }

    var body: some View {
        VStack {
            TextField("Enter location name/ZIP code", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($searchFocused)
                .onChange(of: searchQuery) { newSearchQuery in
                    if newSearchQuery.count > 2 {
                        performSearch()
                    }
                }
                .onSubmit {
                    submitSearch()
                }
            Button {
                getDeviceLocation()
            } label: {
                Image(systemName: "location")
                Text("Use my device's location")
            }
            .tint(.blue)
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
            
            if !searchResults.isEmpty {
                List(searchResults, id: \.self) { item in
                    Button {
                        selectMapItem(item)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unknown")
                            Text(parseAddress(selectedItem: item.placemark))
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                .listStyle(.plain)
            }
            if searchResults.isEmpty {
                Map(coordinateRegion: $region, annotationItems: annotationItems) { item in
                    MapMarker(coordinate: item.coordinate, tint: .red)
                }
            }
            Button {
                handleConfirm()
            } label: {
                Text("Confirm")
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(Color.white)
            }
        }
        .background {
            NavigationLink("", isActive: $confirmPressed) {
                switch nextView {
                case .inIsrael:
                    InIsraelView().applyToolbarHidden()
                case .zmanimLanguage:
                    ZmanimLanguageView().applyToolbarHidden()
                case .tipScreen:
                    TipScreenView().applyToolbarHidden()
                }
            }.hidden()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAdvancedAlert = true
                } label: {
                    Text("Advanced")
                }
            }
        }
        .navigationTitle("Search for a place")
        .snackbar(isShowing: $showNoLocationPermissionSnackbar, title: "No location permission".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.red))
        .snackbar(isShowing: $showNoLocationSetSnackbar, title: "No location set".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.red))
        .snackbar(isShowing: $showRedSnackbar, title: "The application will NOT track your location".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.red))
        .snackbar(isShowing: $showGreenSnackbar, title: "The application will keep requesting your location".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.green))
        .alert("Advanced", isPresented: $showAdvancedAlert) {
            TextField(text: $AdvancedLocationName, prompt: Text("ex: New York")) {}
            TextField(text: $AdvancedLat, prompt: Text("ex: 40.808058")) {}
            TextField(text: $AdvancedLong, prompt: Text("ex: -73.740559")) {}
            TextField(text: $AdvancedElevation, prompt: Text("ex: 30")) {}
            TextField(text: $AdvancedTimezone, prompt: Text("ex: America/New_York")) {}
            Button("OK") {
                defaults.setValue(true, forKey: "useAdvanced")
                defaults.setValue(false, forKey: "useZipcode")
                useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                
                locationName = AdvancedLocationName
                lat = Double(AdvancedLat) ?? 0
                long = Double(AdvancedLong) ?? 0
                let elevation = Double(AdvancedElevation)
                let timezone = AdvancedTimezone

                if timezone == "" { // don't do anything if the timezone was never filled in
                    return
                } else {
                    defaults.setValue(locationName, forKey: "advancedLN")
                    defaults.setValue(lat, forKey: "advancedLat")
                    defaults.setValue(long, forKey: "advancedLong")
                    defaults.setValue(elevation, forKey: "elevation".appending(locationName))
                    defaults.setValue(timezone, forKey: "advancedTimezone")
                }
                region = .init(center: .init(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your location's name, latitude, longitude, elevation, and timezone.")
        }
        .alert("Error", isPresented: $showEmptyError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a valid zipcode or address.")
        }
        .onChange(of: showAdvancedAlert) { newShowAdvancedAlert in
            AdvancedLocationName = ""
            AdvancedLat = ""
            AdvancedLong = ""
            AdvancedElevation = ""
            AdvancedTimezone = ""
        }
    }
    
    private func handleConfirm() {
        if lat == 0 && long == 0 {
            showNoLocationSetSnackbar = true
            return
        }
        if GetUserLocationView.loneView {
            dismiss()// this is good for one view
        } else {
            if timezone.corrected().identifier == "Asia/Jerusalem" {
                nextView = .inIsrael
                confirmPressed = true
            } else if !Locale.isHebrewLocale() {
                defaults.set(false, forKey: "inIsrael")
                defaults.set(true, forKey: "LuachAmudeiHoraah")
                defaults.set(false, forKey: "useElevation")
                nextView = .zmanimLanguage
                confirmPressed = true
            } else {
                defaults.set(false, forKey: "inIsrael")
                defaults.set(true, forKey: "LuachAmudeiHoraah")
                defaults.set(false, forKey: "useElevation")
                defaults.set(true, forKey: "isZmanimInHebrew")
                defaults.set(false, forKey: "isZmanimEnglishTranslated")
                defaults.set(true, forKey: "isSetup")
                if !defaults.bool(forKey: "hasShownTipScreen") {
                    nextView = .tipScreen
                    confirmPressed = true
                    defaults.set(true, forKey: "hasShownTipScreen")
                } else {
                    goBackToRootView()
                }
            }
        }
        GetUserLocationView.loneView = false// reset bool
    }
    
    private func goBackToRootView() {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
          return
        }
        guard let firstWindow = firstScene.windows.first else {
          return
        }
        firstWindow.rootViewController = UIHostingController(rootView: ContentView())
        firstWindow.makeKeyAndVisible()
    }
    
    private func getDeviceLocation() {
        searchResults.removeAll()
        searchQuery = ""
        searchFocused = false
        LocationManager.shared.getUserLocation {
            location in DispatchQueue(label: "mainApp", attributes: .concurrent).async { [self] in
                if location != nil {
                    showGreenSnackbar = true
                    lat = location!.coordinate.latitude
                    long = location!.coordinate.longitude
                    defaults.set(false, forKey: "useZipcode")
                    defaults.set(false, forKey: "useAdvanced")
                    useLocation(location1: false, location2: false, location3: false, location4: false, location5: false)
                    LocationManager.shared.resolveLocationName(with: location!) { [self] locationName in
                        self.locationName = locationName ?? ""
                        region = .init(center: location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
                    }
                } else {
                    showNoLocationPermissionSnackbar = true
                }
            }
        }
    }
    
    private func submitSearch() {
        if searchQuery.isEmpty {
            showEmptyError = true
        } else {// There is some input
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(searchQuery, in: nil, preferredLocale: .current, completionHandler: { i, j in
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
                searchResults.removeAll()
                searchQuery = ""
                searchFocused = false
                region = .init(center: .init(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            })
        }
        showRedSnackbar = true
    }

    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let items = response?.mapItems {
                self.searchResults = items
                addSavedLocation(locationDefault: "location1")
                addSavedLocation(locationDefault: "location2")
                addSavedLocation(locationDefault: "location3")
                addSavedLocation(locationDefault: "location4")
                addSavedLocation(locationDefault: "location5")
            }
        }
    }
    
    func addSavedLocation(locationDefault: String) {
        let location = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: defaults.double(forKey: locationDefault.appending("Lat")), longitude: defaults.double(forKey: locationDefault.appending("Long")))))
        location.name = defaults.string(forKey: locationDefault)
        location.timeZone = TimeZone(identifier: locationDefault.appending("Timezone"))
        if let l = defaults.string(forKey: locationDefault) {
            if !l.isEmpty {
                searchResults.append(location)
            }
        }
    }

    private func selectMapItem(_ item: MKMapItem) {
        guard let coordinate = item.placemark.location?.coordinate else { return }
        
        withAnimation {
            region = .init(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        }
        
        locationName = item.name ?? "Selected Location"
        lat = coordinate.latitude
        long = coordinate.longitude
        timezone = item.timeZone ?? TimeZone.current.corrected()
        
        CLGeocoder().geocodeAddressString(locationName, in: nil, preferredLocale: .current, completionHandler: { [self] i, j in
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
            locationName = name
            if i?.first?.timeZone != nil {
                self.timezone = (i?.first?.timeZone)!
                if locationName == defaults.string(forKey: "location1") ||
                    locationName == defaults.string(forKey: "location2") ||
                    locationName == defaults.string(forKey: "location3") ||
                    locationName == defaults.string(forKey: "location4") ||
                    locationName == defaults.string(forKey: "location5") {
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
            }
        })
        showRedSnackbar = true
        
        searchResults.removeAll()
        searchQuery = ""
        searchFocused = false
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

public enum NextSetupView {
    case inIsrael
    case zmanimLanguage
    case tipScreen
}

#Preview {
    GetUserLocationView()
}
