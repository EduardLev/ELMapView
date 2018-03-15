//
//  Restaurant.swift
//  ELMapView
//
//  Created by Eduard Lev on 3/13/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import CoreLocation

struct Restaurant {
    var name: String
    var address: String
    var website: String
    var image: String
    var location: CLLocation

    static func loadSampleRestaurants() -> [Restaurant] {
        var location = CLLocation(latitude: 40.7085336, longitude: -74.0136127)
        let BaoBaoCafe = Restaurant(name: "Bao Bao Cafe",
                                    address: "106 Greenwich Street, New York, NY",
                                    website: "http://www.baobaonoodle.com",
                                    image: "BaoBaoCafe",
                                    location: location)

        location = CLLocation(latitude: 40.7077115, longitude: -74.0155657)
        let AmericasFinest = Restaurant(name: "America's Finest Deli",
                                     address: "46 Trinity Place, New York, NY",
                                     website: "http://www.americasfinestdelinyc.com",
                                     image: "America's Finest Deli",
                                     location: location)

        location = CLLocation(latitude: 40.7083603, longitude: -74.013317)
        let Subway = Restaurant(name: "Subway",
                             address: "106 Greenwhich Street, New York, NY",
                             website: "http://www.subway.com",
                             image: "Subway",
                            location: location)

        return [BaoBaoCafe, AmericasFinest, Subway]
    }
}
