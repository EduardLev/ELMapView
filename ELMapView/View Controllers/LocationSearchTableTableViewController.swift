//
//  LocationSearchTableTableViewController.swift
//  ELMapView
//
//  Created by Eduard Lev on 3/13/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class LocationSearchTableTableViewController: UITableViewController {
    
    var matchingItems:[MKMapItem] = []
    var matchingGoogleItems:[GooglePlace] = []
    var mapView: MKMapView? = nil
    var googleMapView: GMSMapView! = nil
    var coordinate: CLLocationCoordinate2D!
    var radius: Double = 1000
    private let dataProvider = GoogleDataProvider()
    
    var handleMapSearchDelegate:HandleMapSearch? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func parseAddress(_ selectedItem: MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil)
            ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
            (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil)
            ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
            selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(format:"%@%@%@%@%@%@%@", selectedItem.subThoroughfare ?? "",
            firstSpace, selectedItem.thoroughfare ?? "", comma, selectedItem.locality ?? "",
            secondSpace, selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingGoogleItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let selectedItem = matchingGoogleItems[indexPath.row]
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.address
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedGoogleItem = matchingGoogleItems[indexPath.row]
        handleMapSearchDelegate?.dropGooglePinZoomIn(place: selectedGoogleItem)
        dismiss(animated: true, completion: nil)
        
        /*
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)*/
    }
}

extension LocationSearchTableTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let googleMapView = googleMapView,
            let searchBarText = searchController.searchBar.text else {return}
        
        self.dataProvider.fetchPlacesNearCoordinate(self.coordinate, radius: self.radius, naturalString: searchBarText) { places in
                self.matchingGoogleItems = places
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
