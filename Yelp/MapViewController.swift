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
//    var searchCenter: [String: Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpanMake(0.1, 0.1)), animated: false)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
