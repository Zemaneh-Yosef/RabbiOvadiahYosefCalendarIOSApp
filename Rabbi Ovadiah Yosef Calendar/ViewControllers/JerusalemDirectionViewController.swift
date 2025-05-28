//
//  JerusalemDirectionViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/6/24.
//

import UIKit
import MapKit
import KosherSwift

class JerusalemDirectionViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBAction func zoomIn(_ sender: UIButton) {
        map.setCenter(CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude), animated: false)
        zoomIn()
    }
    @IBAction func zoomOut(_ sender: UIButton) {
        map.setCenter(CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude), animated: false)
        zoomOut()
    }
    @IBAction func info(_ sender: UIButton) {
        var longInfoMessage: String
        if Locale.isHebrewLocale() {
            longInfoMessage = "בעת התפילה בעמידה, יש להכווין את עצמו לכיוון ירושלים, בית המקדש ואזור קודש הקדשים (ברכות בבלי ל: א), (מלכים א\' ח: לה-מח, ודברי הימים ב\' ו: לב). לקביעת הכיוון הנכון ניתן להשתמש בשיטת \"קו רומב\" המציירת קו ממקום המתפלל ישירות לנקודה ספציפית (שבמקרה שלנו, יהיה זה הר הבית). לאחר שהקו נמשך, מומלץ להתפלל לפי הכיוון של הקו באמצעות התאמת כיוון התפילה לזווית המדרגה שלו. יש לשים לב כי גם אם ארון הקודש בבית הכנסת בו אתה נמצא מותקף, לא רקוב זה אינו מנותק מהמתפללים האחרים. במקום זאת, יש להתאים רק את הראש לכיוון הנכון."
        } else {
            longInfoMessage = "When praying the Amidah, one should direct himself towards Israel, Jerusalem, the temple mount and the Kodesh Hakodashim (Holy of Holies) area (Berakhot Bavli 30a, based on Kings I 8:35–48 & Chronicles II 6:32). Determining which direction that is in can be done through the \"Rhumb line\" method, which \"draws\" a line from one\'s location to a specific point (which in our case, would be the Temple mount). Once the line is drawn, you are expected to pray in the direction the line is drawn in through matching your direction with its degree angle. Please note that even if the Aron in the synagogue that you are in is misplaced, you should not separate from the others. Rather, you should only adjust your head to the right direction."
        }
        
        var alertController = UIAlertController(title: "Jerusalem Direction Explained".localized(), message: longInfoMessage, preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Jerusalem Direction Explained".localized(), message: longInfoMessage, preferredStyle: .alert)
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in }
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    @IBOutlet weak var map: MKMapView!
    @IBAction func back(_ sender: UIButton) {
        super.dismiss(animated: true)
    }
    @IBOutlet weak var back: UIButton!
    
    var locationManager = CLLocationManager()
    var northPointerImageView = UIImageView(image: UIImage(named: "North Pointer"))
    var annotationView = CustomMarkerAnnotationView()
    let jerGeolocation = GeoLocation(locationName: "Jerusalem", latitude: 31.778015, longitude: 35.235413, timeZone: TimeZone.current)
    var currentGeolocation = GlobalStruct.geoLocation
    var isCompassGreen = false
    public static var hideQuitButton: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if JerusalemDirectionViewController.hideQuitButton {
            back.isHidden = true
        }
        
        map.delegate = self
        locationManager.delegate = self
        
        // Start location services to get the true heading.
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
        
        //Start heading updating.
        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
        }
        
        // Define the center coordinate using your current location
        let centerCoordinate = CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude)
        
        // Define the region span (in degrees)
        let regionSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        // Create a region based on the center coordinate and span
        let region = MKCoordinateRegion(center: centerCoordinate, span: regionSpan)
        
        // Set the region on the map
        map.setRegion(region, animated: true)
        map.showsUserLocation = true
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.isPitchEnabled = false
        map.isUserInteractionEnabled = false // if we want to enable map rotation, this needs to be implemented for the compass to turn green: https://stackoverflow.com/questions/26530546/track-mkmapview-rotation
        map.userTrackingMode = .none
        
        // Define Jerusalem coordinates
        let jerusalemCoordinate = CLLocationCoordinate2D(latitude: 31.778015, longitude: 35.235413)
        
        // Create polyline from user's location to Jerusalem
        let userLocationCoordinate = CLLocationCoordinate2D(latitude: GlobalStruct.geoLocation.latitude, longitude: GlobalStruct.geoLocation.longitude)
        let coordinates = [userLocationCoordinate, jerusalemCoordinate]
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        // Add the polyline overlay to the map
        map.addOverlay(polyline)
        
        // Set up the northPointerImageView
        northPointerImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 70)
        map.addSubview(northPointerImageView)
        
        let jerusalemAnnotation = MKPointAnnotation()
        jerusalemAnnotation.coordinate = jerusalemCoordinate
        jerusalemAnnotation.title = "Jerusalem".localized()
        jerusalemAnnotation.subtitle = "Holy of Holies".localized()
        map.addAnnotation(jerusalemAnnotation)
        
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = userLocationCoordinate
        map.addAnnotation(userAnnotation)
    }
    
    func zoomIn() {
        var region = map.region
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
        map.setRegion(region, animated: true)
    }
    
    func zoomOut() {
        var region = map.region
        let maxLatitudeDelta: CLLocationDegrees = 180
        let maxLongitudeDelta: CLLocationDegrees = 180
        
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2, maxLatitudeDelta)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2, maxLongitudeDelta)
        
        map.setRegion(region, animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait // disable landscape orientation
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Return nil for user location annotation
        guard !(annotation is MKUserLocation) else { return nil }
        guard !(annotation.title == "Jerusalem".localized()) else { return nil }
        
        // Reuse or create a custom annotation view
        var customAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customAnnotation") as? CustomMarkerAnnotationView
        if customAnnotationView == nil {
            customAnnotationView = CustomMarkerAnnotationView(annotation: annotation, reuseIdentifier: "customAnnotation")
        } else {
            customAnnotationView?.annotation = annotation
        }
        annotationView = customAnnotationView!
        return customAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if newHeading.headingAccuracy < 0 {
            return
        }
        
        // Get the heading (direction)
        let heading = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading)
        
        let bearing = currentGeolocation.getRhumbLineBearing(location: jerGeolocation)
        
        let directionDifference = abs(Double(heading) - bearing)
        
        let threshold = 10.0
        
        if directionDifference <= threshold {
            if (!isCompassGreen) {
                DispatchQueue.main.async { [self] in
                    annotationView.image = nil
                    annotationView.image = UIImage(named: "green_compass")
                    isCompassGreen = true
                }
            }
        } else {
            if (isCompassGreen) {
                DispatchQueue.main.async { [self] in
                    annotationView.image = nil
                    annotationView.image = UIImage(named: "compass_without_text")
                    isCompassGreen = false
                }
            }
        }
        
        // Convert heading from degrees to radians
        let headingRadians = CGFloat(heading) * .pi / 180.0
        
        // Rotate the image view using CGAffineTransform
        DispatchQueue.main.async { [self] in
            annotationView.transform = CGAffineTransform(rotationAngle: headingRadians)
        }
    }
}

class CustomMarkerAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.image = UIImage(named: "compass_without_text") // start with regular compass
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
