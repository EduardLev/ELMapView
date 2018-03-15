//
//  LocationSearchTableTableViewController.swift
//  ELMapView
//
//  Created by Eduard Lev on 3/13/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTableTableViewController: UITableViewController {
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
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
        return matchingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}

extension LocationSearchTableTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else {return}
        let request = MKLocalSearchRequest() // creating the request object
        request.naturalLanguageQuery = searchBarText // setting the request to the user search
        request.region = mapView.region // setting the request region to the current visible reg.
        
        let search = MKLocalSearch(request: request) // initiation of the search request
        search.start { (response, error) in
            guard let response = response else { return }
            self.matchingItems = response.mapItems // sets my array to the array of map items
            self.tableView.reloadData()
        }
    }
}
