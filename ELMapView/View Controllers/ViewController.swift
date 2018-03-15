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
import GoogleMaps

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
    func dropGooglePinZoomIn(place: GooglePlace)
}

class ViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var restaurants: [Restaurant] = []
    var dictRestaurants: [String : Restaurant] = [:]
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 1000 // in meters
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    var selectedPlace: GooglePlace?
    var selectedCoordinate: CLLocationCoordinate2D!
    var locationSearchTable: LocationSearchTableTableViewController!
    
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var turnToTechLOGO: UIImageView!
    var resultsSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var selectedAnnotation:MKAnnotation? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleMapView.delegate = self
        
        startStandardUpdates()
        setupMapView()
        addTurnToTechPin()
        addRestaurantPins()
        createSearchResultsController()
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
        locationSearchTable =
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
        locationSearchTable.googleMapView = googleMapView
        locationSearchTable.coordinate = self.selectedCoordinate
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func startStandardUpdates() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.requestWhenInUseAuthorization()
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
        case 0: //mapView.mapType = MKMapType.standard
                googleMapView.mapType = .normal
        case 1: //mapView.mapType = MKMapType.hybrid
                googleMapView.mapType = .hybrid
        case 2: //mapView.mapType = MKMapType.satellite
                googleMapView.mapType = .satellite
        default: break
        }
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            let text = lines.joined(separator: "\n")
            print(text)
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }

    private func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        googleMapView.clear()
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            places.forEach {
                let marker = PlaceMarker(place: $0)
                marker.map = self.googleMapView
            }
        }
    }
}

// CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        
        locationManager.startUpdatingLocation()
        googleMapView.isMyLocationEnabled = true
        googleMapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        googleMapView.camera = GMSCameraPosition(target: location.coordinate,
                                           zoom: 15, bearing:0, viewingAngle: 0)
        fetchNearbyPlaces(coordinate: location.coordinate)
        self.locationSearchTable.coordinate = location.coordinate
        locationManager.stopUpdatingLocation()
    }
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        
        //clear existing pins
        //mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    func dropGooglePinZoomIn(place: GooglePlace) {
        let marker = PlaceMarker(place: place)
        self.googleMapView.clear()
        marker.map = self.googleMapView
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // return nil so map view draws "blue dot" for standard user location
            return nil
        }

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView?.tintColor = .orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(), size:smallSquare))
        button.setBackgroundImage(UIImage(named: "World"), for: .normal)
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
            selectedURL = "http://www.turntotech.io"
        }
    
        let webViewVC = WebViewController()
        webViewVC.urlString = selectedURL
        self.navigationController?.pushViewController(webViewVC, animated: true)
        //self.present(webViewVC, animated: true, completion: nil)
    }
    
    @objc func goToGoogleWebsite() {
        print("this is happening")
        guard let placeMarker = self.googleMapView.selectedMarker as? PlaceMarker else { return }
        let selectedString = placeMarker.place.name
        let selectedStringWithPlus = selectedString.replacingOccurrences(of: " ", with: "+")
        let selectedURL = "http://www.google.com/search?safe=active&q=\(selectedStringWithPlus)"
        let webViewVC = WebViewController()
        webViewVC.urlString = selectedURL
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region:MKCoordinateRegion =
            MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 250, 250)
        self.mapView.setRegion(region, animated: true)
    }
}

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
        self.locationSearchTable.coordinate = position.target
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        // code here
      //      addressLabel.lock()
        
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        
        marker.tracksInfoWindowChanges = true
        
        guard let placeMarker = marker as? PlaceMarker else {
            return nil
        }
        
        guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
            return nil
        }
        
        infoView.nameLabel.text = placeMarker.place.name
        if let photo = placeMarker.place.photo {
            infoView.placePhoto.image = photo
        } else {
            infoView.placePhoto.image = UIImage(named: "generic")
        }
        
        return infoView
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.goToGoogleWebsite()
    }
    
}

