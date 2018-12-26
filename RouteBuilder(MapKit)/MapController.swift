//
//  MapController.swift
//  RouteBuilder(MapKit)
//
//  Created by Ruslan on 12/26/18.
//  Copyright © 2018 Ruslan Naumenko. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController {
    
    var locationManager: CLLocationManager?
    var sourceLocation:CLLocationCoordinate2D?
    var destinationLocation:CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = MKMapType.standard
        case 1:
            mapView.mapType = MKMapType.satellite
        case 2:
            mapView.mapType = MKMapType.hybrid
        default:
            print("Unknown Segment Controller Index (\(sender.selectedSegmentIndex))")
        }
    }

    @IBAction func geolocationButton(_ sender: UIButton) {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            displayAlert(message: "Location access is now allowed")
        case .authorizedAlways, .authorizedWhenInUse:
            let location = locationManager?.location?.coordinate
            let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake((location?.latitude)!, (location?.longitude)!)
            let region:MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: span)
            mapView.setRegion(region, animated: true)
            
            self.locationManager?.stopUpdatingLocation()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation!)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation!)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {
                if let error = error {
                    self.displayAlert(message: "cannot find any route")
                    print(error)
                }
                return
            }
            
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
        }
    }
    
    private func displayAlert(message: String)
    {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }
        } ))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
}
