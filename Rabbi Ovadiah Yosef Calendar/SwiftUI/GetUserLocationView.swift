//
//  GetUserLocationView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 4/6/25.
//

import SwiftUI
import MapKit

@available(iOS 15.0, *)
struct GetUserLocationView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137),
        span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
    )

    @State private var annotation: IdentifiablePlace? = nil
    @State private var searchQuery = ""
    @FocusState private var searchFocused: Bool

    public static var loneView: Bool = false
    @State var locationName: String = ""
    @State var lat: Double = 0
    @State var long: Double = 0
    @State var timezone: TimeZone = TimeZone.current
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    @State var chosenLocationAnnotation = MKPointAnnotation()
    @State var searchResults: [MKMapItem] = []
    @State var localSearch: MKLocalSearch?
    
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

    var body: some View {
        VStack {
            TextField("Search for a location", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .focused($searchFocused)
                .onSubmit {
                    performSearch()
                }

            if !searchResults.isEmpty {
                List(searchResults, id: \.self) { item in
                    Button {
                        selectMapItem(item)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unknown")
                            if let coord = item.placemark.location?.coordinate {
                                Text("\(coord.latitude), \(coord.longitude)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }

            Map(coordinateRegion: $region, annotationItems: annotation.map { [$0] } ?? []) { place in
                MapPin(coordinate: place.location)
            }
            .frame(height: 300)
            .gesture(
                TapGesture().onEnded { location in
                    // In SwiftUI Map, we need to use Coordinator to get tap location, which is tricky.
                    // So this will require a UIKit wrapper for full tap gesture support.
                }
            )
            .cornerRadius(10)
            .padding()

            VStack(spacing: 12) {
//                HStack {
//                    TextField("Manual Latitude", text: $manualLat)
//                        .keyboardType(.decimalPad)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                    TextField("Manual Longitude", text: $manualLong)
//                        .keyboardType(.decimalPad)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                    Button("Use") {
//                        useManualLocation()
//                    }
//                }
//
//                HStack {
//                    TextField("ZIP Code", text: $zipCode)
//                        .keyboardType(.numberPad)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                    Button("Use ZIP") {
//                        useZipcodeLocation()
//                    }
//                }
            }
            .padding()

            Spacer()
        }
        .onAppear {
            restoreLastUsedLocation()
        }
        .navigationTitle("Select Location")
    }

    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let items = response?.mapItems {
                self.searchResults = items
            }
        }
    }

    private func selectMapItem(_ item: MKMapItem) {
        guard let coordinate = item.placemark.location?.coordinate else { return }

        region.center = coordinate
        annotation = IdentifiablePlace(location: coordinate)

        let locationName = item.name ?? "Selected Location"
        let timezone = item.timeZone ?? TimeZone.current

        saveToDefaults(name: locationName, lat: coordinate.latitude, long: coordinate.longitude, tz: timezone)

        searchResults.removeAll()
        searchQuery = ""
        searchFocused = false
    }

    private func useManualLocation() {
//        guard let lat = Double(manualLat), let long = Double(manualLong) else { return }
//        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//        annotation = IdentifiablePlace(location: coordinate)
//        region.center = coordinate
//
        saveToDefaults(name: "Manual Location", lat: lat, long: long, tz: TimeZone.current)
    }

    private func useZipcodeLocation() {
//        guard !zipCode.isEmpty else { return }
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = zipCode
//
//        let search = MKLocalSearch(request: request)
//        search.start { response, error in
//            if let item = response?.mapItems.first,
//               let coord = item.placemark.location?.coordinate {
//                annotation = IdentifiablePlace(location: coord)
//                region.center = coord
//
//                let name = item.name ?? "Zipcode Location"
//                let timezone = item.timeZone ?? TimeZone.current
//
//                saveToDefaults(name: name, lat: coord.latitude, long: coord.longitude, tz: timezone)
//            }
//        }
    }

    private func saveToDefaults(name: String, lat: Double, long: Double, tz: TimeZone) {
        defaults.set(name, forKey: "locationName")
        defaults.set(lat, forKey: "lat")
        defaults.set(long, forKey: "long")
        defaults.set(tz.identifier, forKey: "timezone")
    }

    private func restoreLastUsedLocation() {
        if let lat = defaults.value(forKey: "lat") as? Double,
           let long = defaults.value(forKey: "long") as? Double {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation = IdentifiablePlace(location: coord)
            region.center = coord
        }
    }
}

struct IdentifiablePlace: Identifiable {
    let id = UUID()
    let location: CLLocationCoordinate2D
}


#Preview {
    if #available(iOS 15.0, *) {
        GetUserLocationView()
    } else {
        // Fallback on earlier versions
    }
}
