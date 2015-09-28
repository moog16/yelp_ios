//
//  MapViewController.swift
//  Yelp
//
//  Created by Matthew Goo on 9/25/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var businesses: [Business]!
    var searchCenter: [Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.749, green: 0.0902, blue: 0, alpha: 1.0)
        
        var centerLat = 37.783333
        var centerLong = -122.416667
        if let searchCenter = searchCenter {
            centerLat = searchCenter[0]
            centerLong = searchCenter[1]
        }
        
        mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(centerLat, centerLong), MKCoordinateSpanMake(0.1, 0.1)), animated: false)
        
        for business in businesses {
            if let address = business.address {
                addPinWithAddressString(address)
            }
        }
        
    }

    func addPinWithAddressString(address: String) {
        CLGeocoder().geocodeAddressString(address) {(placemark: [CLPlacemark]?, error: NSError?) -> Void in
            if let placemark = placemark {
                if let location = placemark[0].location {
                    self.addPin(location.coordinate.latitude, longitude: location.coordinate.longitude)
                }
            }

        }
    }
    
    func addPin(latitude: Double = 37.783333, longitude: Double = -122.416667) {
        let annotation = MKPointAnnotation()
        let locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
        annotation.coordinate = locationCoordinate
        mapView.addAnnotation(annotation)
    }

}
