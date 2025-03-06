import SwiftUI
import MapKit
import KosherSwift

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
            Text(Locale.isHebrewLocale() ? "בעת התפילה בעמידה, יש להכווין את עצמו לכיוון ירושלים, בית המקדש ואזור קודש הקדשים (ברכות בבלי ל: א), (מלכים א\' ח: לה-מח, ודברי הימים ב\' ו: לב). לקביעת הכיוון הנכון ניתן להשתמש בשיטת \"קו רומב\" המציירת קו ממקום המתפלל ישירות לנקודה ספציפית (שבמקרה שלנו, יהיה זה הר הבית). לאחר שהקו נמשך, מומלץ להתפלל לפי הכיוון של הקו באמצעות התאמת כיוון התפילה לזווית המדרגה שלו. יש לשים לב כי גם אם ארון הקודש בבית הכנסת בו אתה נמצא מותקף, לא רקוב זה אינו מנותק מהמתפללים האחרים. במקום זאת, יש להתאים רק את הראש לכיוון הנכון." : "When praying the Amidah, one should direct himself towards Israel, Jerusalem, the temple mount and the Kodesh Hakodashim (Holy of Holies) area (Berakhot Bavli 30a, based on Kings I 8:35–48 & Chronicles II 6:32). Determining which direction that is in can be done through the \"Rhumb line\" method, which \"draws\" a line from one\'s location to a specific point (which in our case, would be the Temple mount). Once the line is drawn, you are expected to pray in the direction the line is drawn in through matching your direction with its degree angle. Please note that even if the Aron in the synagogue that you are in is misplaced, you should not separate from the others. Rather, you should only adjust your head to the right direction.")
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
}

class CompassManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var heading: Double?
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
            heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        }
    }
}
