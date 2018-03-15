//
//  ViewController.swift
//  ELMapView
//
//  Created by Eduard Lev on 3/13/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class ViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var restaurants: [Restaurant] = []
    var dictRestaurants: [String : Restaurant] = [:]
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var turnToTechLOGO: UIImageView!
    var resultsSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var selectedAnnotation:MKAnnotation? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startStandardUpdates()
        setupMapView()
        addTurnToTechPin()
        createSearchResultsController()
        addRestaurantPins()
    }
    
    func addRestaurantPins() {
        restaurants = Restaurant.loadSampleRestaurants()

        for rest in restaurants {
            let annotation = MKPointAnnotation()
            annotation.coordinate = rest.location.coordinate
            annotation.title = rest.name
            annotation.subtitle = rest.address
            self.mapView.addAnnotation(annotation)
            dictRestaurants[rest.name] = rest
        }
    }
    
    func createSearchResultsController() {
        // Instantiates the view controller programmatically
        let locationSearchTable =
            storyboard?.instantiateViewController(withIdentifier: "LocationSearchTable") as!
        LocationSearchTableTableViewController
        resultsSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultsSearchController?.searchResultsUpdater = locationSearchTable
        
        // creates the search bar and adds it to the current navigation item
        let searchBar = resultsSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultsSearchController?.searchBar
        
        resultsSearchController?.hidesNavigationBarDuringPresentation = false
        resultsSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func startStandardUpdates() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.requestAlwaysAuthorization()
        /*if CLLocationManager.locationServicesEnabled() {
         locationManager.startUpdatingLocation()
         }*/
    }
    
    func setupMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.bringSubview(toFront: turnToTechLOGO)
    }
    
    func addTurnToTechPin() {
        // Place a single pin
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 40.7084896,
                                                       longitude: -74.0147607)
        annotation.title = "Turn To Tech"
        annotation.subtitle = "Learn To Program"
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func selectMapTypeValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: mapView.mapType = MKMapType.standard
        case 1: mapView.mapType = MKMapType.hybrid
        case 2: mapView.mapType = MKMapType.satellite
        default: break
        }
    }
}

// CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    /*func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated:true)
        }
    }*/
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        
        //clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        /*let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)*/
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // return nil so map view draws "blue dot" for standard user location
            return nil
        }
        var selectedRestaurant: Restaurant
        var selectedImageString: String?
        for rest in restaurants {
            if rest.name == annotation.title!! {
                selectedRestaurant = rest
                selectedImageString = selectedRestaurant.image
            }
        }
        
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView?.tintColor = .orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(), size:smallSquare))
        
        if let selectedImageString = selectedImageString {
            button.setBackgroundImage(UIImage(named: selectedImageString), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "World"), for: .normal)
        }
        button.addTarget(self, action: #selector(goToWebsite), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    @objc func goToWebsite() {
        let selectedAnnotation = self.mapView.selectedAnnotations[0]
        var selectedURL:String
        if let selectedRestaurant = dictRestaurants[selectedAnnotation.title!!] {
            selectedURL = selectedRestaurant.website
        } else {
            let selectedString = selectedAnnotation.title
            let inputString = selectedString??.replacingOccurrences(of: " ", with: "+")
            selectedURL = "https://www.google.com/search?safe=active&q=\(inputString!)"
        }
    
        let webViewVC = WebViewController()
        webViewVC.urlString = selectedURL
        self.navigationController?.pushViewController(webViewVC, animated: true)
        //self.present(webViewVC, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region:MKCoordinateRegion =
            MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 250, 250)
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
}

