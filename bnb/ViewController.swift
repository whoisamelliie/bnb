//
//  ViewController.swift
//  bnb
//
//  Created by Amelie Baimukanova on 19.01.2024.
//

import UIKit
import MapKit
class ViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var labelCountry: UILabel!
    @IBOutlet weak var labelHotel: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    
    var country = ""
    var hotel = ""
    var imagename = ""
   // var price = ""
    
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var followMe = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap))
        
        mapDragRecognizer.delegate = self
        
        mapview.addGestureRecognizer(mapDragRecognizer)
        
        let lat:CLLocationDegrees =  1.924992
        let long:CLLocationDegrees = 73.399658
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
        let anotation = MKPointAnnotation()
        anotation.coordinate = location
        anotation.title = "Title"
        anotation.subtitle = "subtitle"
        mapview.addAnnotation(anotation)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction))
        longPress.minimumPressDuration = 2
        mapview.addGestureRecognizer(longPress)
        mapview.delegate = self
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        
        print(userLocation)
        if followMe {
            let latDelta:CLLocationDegrees = 0.01
            let longDelta:CLLocationDegrees = 0.01
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapview.setRegion(region, animated: true)
        }
    }
    
    @IBAction func showMyLocation(_ sender: Any) {
        followMe = true
        
    }
    @objc func didDragMap(gestureRecognizer: UIGestureRecognizer) {
       
        if (gestureRecognizer.state == UIGestureRecognizer.State.began) {
            followMe = false
            print("Map drag began")
        }
        
        if (gestureRecognizer.state == UIGestureRecognizer.State.ended) {
            print("Map drag ended")
        }
    }
    @objc func longPressAction(gestureRecognizer: UIGestureRecognizer) {
        print("gestureRecognizer")
        let touchPoint = gestureRecognizer.location(in: mapview)
        let newCoor: CLLocationCoordinate2D = mapview.convert(touchPoint, toCoordinateFrom: mapview)
        let anotation = MKPointAnnotation()
        
        anotation.coordinate = newCoor
        anotation.title = "Title"
        anotation.subtitle = "subtitle"
        
        mapview.addAnnotation(anotation)
    }
    // MARK: -  MapView delegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print(view.annotation?.title)
        
        
        let _:CLLocation = CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
        
        
//        let meters:CLLocationDistance = location.distance(from: userLocation)
//        distanceLabel.text = String(format: "Distance: %.2f m", meters)
        
        
       
        let sourceLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let destinationLocation = CLLocationCoordinate2D(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
        
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = sourceMapItem
       
        directionRequest.destination = destinationMapItem
       
        directionRequest.transportType = .automobile
        
        
        let directions = MKDirections(request: directionRequest)
        
        
        directions.calculate {
            (response, error) -> Void in
            
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
           
            let route = response.routes[0]
            
            self.mapview.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
           
            let rect = route.polyline.boundingMapRect
            self.mapview.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       
        let renderer = MKPolylineRenderer(overlay: overlay)
       
        renderer.strokeColor = UIColor.red
        
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
}



    
