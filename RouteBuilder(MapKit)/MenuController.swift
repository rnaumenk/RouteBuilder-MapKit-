//
//  MenuController.swift
//  RouteBuilder(MapKit)
//
//  Created by Ruslan on 12/26/18.
//  Copyright © 2018 Ruslan Naumenko. All rights reserved.
//

import UIKit
import MapKit

class MenuController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var sourceLocation : CLLocationCoordinate2D?
    private var destinationLocation : CLLocationCoordinate2D?
    private let dispatchGroup = DispatchGroup()
    private let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    @IBAction func goButton(_ sender: UIButton) {
        findLocationsAndGoToMap()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fromTextField.resignFirstResponder()
        toTextField.resignFirstResponder()
    }
    
    @IBAction func myLocationButton(_ sender: UIButton) {
        
        if fromTextField.isHidden == false {
            sender.setTitle("Choose a particular location", for: .normal)
            fromTextField.isHidden = true
        }
        else {
            sender.setTitle("Choose my location", for: .normal)
            fromTextField.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromTextField.delegate = self
        toTextField.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startUpdatingLocation()
        }
    }
    
    private func findLocationsAndGoToMap() {
        if fromTextField.isHidden {
            self.sourceLocation = self.locationManager.location?.coordinate
        }
        else {
            dispatchGroup.enter()
            geocodeSourceLocation()
        }
        dispatchGroup.enter()
        geocodeDestinationLocation()
        dispatchGroup.notify(queue: .main) {
            if self.sourceLocation == nil {
                self.displayAlert(message: "Location access is not allowed")
            }
            else {
                self.performSegue(withIdentifier: "map", sender: self)
            }
        }
    }
    
    private func geocodeSourceLocation() {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(fromTextField.text!) { (placemark, error) in
            guard let placemark = placemark else {
                if let error = error {
                    self.displayAlert(message: "wrong source location")
                    print(error)
                }
                return
            }
            let location = placemark[0].location
            self.sourceLocation = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
            self.dispatchGroup.leave()
        }
    }
    
    private func geocodeDestinationLocation() {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(toTextField.text!) { (placemark, error) in
            guard let placemark = placemark else {
                if let error = error {
                    self.displayAlert(message: "wrong destination location")
                    print(error)
                }
                return
            }
            let location = placemark[0].location
            self.destinationLocation = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
            self.dispatchGroup.leave()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let src = segue.source as! MenuController
        let dst = segue.destination as! MapController
        
        dst.sourceLocation = src.sourceLocation
        dst.destinationLocation = src.destinationLocation
        dst.locationManager = src.locationManager
        
        src.sourceLocation = nil
        src.destinationLocation = nil
        
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

extension MenuController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        findLocationsAndGoToMap()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let searchController = storyBoard.instantiateViewController(withIdentifier: "SearchController") as! SearchController
        searchController.modalTransitionStyle = .coverVertical
        
        if textField == fromTextField {
            searchController.field = ("fromTextField", fromTextField.text) as? (String, String)
        }
        else {
            searchController.field = ("toTextField", toTextField.text) as? (String, String)
        }
        present(searchController, animated: true, completion: nil)
    }
}
