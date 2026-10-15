import SwiftUI
import MapKit
import KosherSwift
import SwiftUISnackbar

struct JerDirectionView: View {
    var body: some View {
        if #available(iOS 17.0, *) {// fun fact, SwiftUI Maps don't support Polylines until iOS 17! How fun!
            JerusalemDirectionView()
        } else {// revert to UIKit/Storyboard view
            UIKitJerDirectionControllerView()
        }
    }
}

struct UIKitJerDirectionControllerView : UIViewControllerRepresentable {
     func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
     func makeUIViewController(context: Context) -> some UIViewController {
         JerusalemDirectionViewController.hideQuitButton = true
         return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "jerDirection")
     }
}

@available(iOS 17.0, *)
struct JerusalemDirectionView: View {
    @StateObject private var locationManager = CompassManager()
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    @State var latDelta = 0.05
    @State var longDelta = 0.05
    @State private var isCompassGreen = false
    @State private var compassRotation: Angle = .zero
    @State private var showInfoAlert = false
    
    @State private var showLowAccuracySnackbar = false
    @State private var showOkayAccuracySnackbar = false
    @State private var showUnreliableSnackbar = false
    
    let jerusalemLocation = CLLocationCoordinate2D(latitude: 31.778015, longitude: 35.235413)
    
    let polyline: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude), // current location
        CLLocationCoordinate2D(latitude: 31.778015, longitude: 35.235413), // Jerusalem
    ]
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition, interactionModes: []) {
                UserAnnotation()
                Annotation("", coordinate: jerusalemLocation) {
                    Text("Holy of Holies".localized())
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }
                MapPolyline(coordinates: polyline)
                    .stroke(.blue, lineWidth: 3)
            }
            .disabled(true)
            
            // Compass centered in the middle of the map
            Image(isCompassGreen ? "green_compass" : "compass_without_text")
                .rotationEffect(compassRotation)
                .onReceive(locationManager.$heading) { heading in
                    updateCompass(heading: heading)
                }
            
            // Aligning elements using GeometryReader for absolute positioning
            GeometryReader { geometry in
                VStack {
                    HStack {// North Pointer in the top-left corner
                        Image("North Pointer")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 70)
                        Spacer()
                    }
                    Spacer()
                    
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Button {
                                zoomIn()
                            } label: {
                                Image(systemName: "plus.magnifyingglass")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2)) // Border
                                    .foregroundStyle(Color.blue)
                            }
                            
                            Divider() // Line between buttons
                                .frame(width: 50) // Controls the width of the divider
                            
                            Button {
                                zoomOut()
                            } label: {
                                Image(systemName: "minus.magnifyingglass")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2)) // Border
                                    .foregroundStyle(Color.blue)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            updateSnackbarStatus(for: locationManager.accuracyStatus)
        }
        .onChange(of: locationManager.accuracyStatus) { _, newStatus in
            updateSnackbarStatus(for: newStatus)
        }
        .snackbar(isShowing: $showLowAccuracySnackbar, title: "Sensor accuracy is low".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.orange))
        .snackbar(isShowing: $showOkayAccuracySnackbar, title: "Sensor accuracy is okay".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.green))
        .snackbar(isShowing: $showUnreliableSnackbar, title: "No sensor found or unreliable".localized(), text: "[Tap to dismiss]".localized(), style: .custom(.red))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showInfoAlert = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .alert("Jerusalem Direction Explained".localized(), isPresented: $showInfoAlert) {
            Button("Dismiss", role: .cancel) { }
        } message: {
            Text("When praying the Amidah, one should direct himself towards Israel, Jerusalem, the temple mount and the Kodesh Hakodashim (Holy of Holies) area (Berakhot Bavli 30a, based on Kings I 8:35–48 & Chronicles II 6:32). Determining which direction that is in can be done through the \"Rhumb line\" method, which \"draws\" a line from one\'s location to a specific point (which in our case, would be the Temple mount). This was the preferred method of Maran ZT\"L while he was traveling to America. Once the circle turns green, you are facing the ideal direction towards the temple mount. Please keep in mind that even if the Aron in the synagogue that you are in is misplaced, you should not separate from the others. Rather, you should only adjust your head to the right direction.")
        }.textCase(nil)
    }
    
    private func updateCompass(heading: Double?) {
        guard let heading = heading else { return }
        let bearing = locationManager.currentGeolocation.getRhumbLineBearing(location: GeoLocation(locationName: "Jerusalem", latitude: 31.778015, longitude: 35.235413, timeZone: TimeZone.current))
        let directionDifference = abs(heading - bearing)
        let threshold = 10.0
        
        isCompassGreen = directionDifference <= threshold
        compassRotation = Angle(degrees: heading)
    }
    
    private func zoomIn() {
        withAnimation {
            latDelta /= 2
            longDelta /= 2
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude),
                span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)))
        }
    }
    
    private func zoomOut() {
        withAnimation {
            latDelta = min(latDelta * 2, 180)
            longDelta = min(longDelta * 2, 180)
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude),
                span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)))
        }
    }
    
    private func updateSnackbarStatus(for status: CompassAccuracyStatus) {
        showLowAccuracySnackbar = false
        showOkayAccuracySnackbar = false
        showUnreliableSnackbar = false
        
        switch status {
        case .low:
            showLowAccuracySnackbar = true
        case .okay:
            showOkayAccuracySnackbar = true
        case .unreliable:
            showUnreliableSnackbar = true
        case .unknown:
            break
        }
    }
}

class CompassManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var heading: Double?
    @Published var accuracyStatus: CompassAccuracyStatus = .unknown
    
    var currentGeolocation = GlobalStruct.geoLocation
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        if CLLocationManager.headingAvailable() {
            manager.headingFilter = 1
            manager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy >= 0 {
            heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        }
        
        let newStatus: CompassAccuracyStatus
        if newHeading.headingAccuracy < 0 {
            newStatus = .unreliable
        } else if newHeading.headingAccuracy > 25.0 {// 25+ degrees of error is generally considered low accuracy
            newStatus = .low
        } else {
            newStatus = .okay
        }
        
        // Only update if the status category actually changed to prevent snackbar spam
        if newStatus != accuracyStatus {
            accuracyStatus = newStatus
        }
    }
}

enum CompassAccuracyStatus: Equatable {
    case unknown
    case unreliable
    case low
    case okay
}
