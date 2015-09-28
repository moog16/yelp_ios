//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreLocation

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {
    @IBOutlet weak var filtersBarButton: UIBarButtonItem!
    var businesses: [Business]!
    var currentFilters: [String: AnyObject]?
    var defaultCurrentFilters = [String: AnyObject]()
    let metersPerMile = 1609.34
    var searchBar: UISearchBar?
    var locationManager : CLLocationManager!
    @IBOutlet weak var noResultsFoundView: UIView!
    @IBOutlet weak var filtersAppliedLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.749, green: 0.0902, blue: 0, alpha: 1.0)
        
        let navigationSearchBar = UISearchBar()
        navigationSearchBar.sizeToFit()
        navigationItem.titleView = navigationSearchBar
        searchBar = navigationSearchBar
        navigationSearchBar.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        let defaultCenterLocation: [Double] = [37.785771, -122.406165]
        defaultCurrentFilters["categories"] = []
        defaultCurrentFilters["deals"] = false as Bool
        defaultCurrentFilters["distance"] = metersPerMile
        defaultCurrentFilters["sort"] = 1
        defaultCurrentFilters["location"] = defaultCenterLocation
        
        filtersAppliedLabel.text = getFiltersText(defaultCurrentFilters)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: nil, deals: false, radius: metersPerMile, location: defaultCenterLocation) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.showError(businesses)
        }
    }
    
    func getFiltersText(filters: [String: AnyObject]) -> String {
        var filtersAppliedText = ""
        
        if let categories = filters["categories"] {
            for category in categories as! NSArray {
                filtersAppliedText += "\(category)"
            }
        }
        if filters["deals"] as! Bool == true {
            filtersAppliedText += "deals "
        }

        if let distance = filters["distance"] {
            let distanceInMiles = distance as! Double/metersPerMile
            filtersAppliedText += "\(distanceInMiles) miles "
        }
        
        if let sort = filters["sort"] {
            filtersAppliedText += "sort by: \(YelpSortMode(rawValue: sort as! Int)!.label)"
        }
        return filtersAppliedText
    }
    
    func showError(businesses: [Business]?) {
        noResultsFoundView.hidden = true
        if businesses != nil {
            if businesses!.count == 0 {
                noResultsFoundView.hidden = false
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar?.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        searchBar?.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let currentFilters = currentFilters {
            search(currentFilters)
        } else {
            search(defaultCurrentFilters)
        }
        searchBar.endEditing(true)
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextViewController = segue.destinationViewController
        if nextViewController is UINavigationController {
            let navigationController = nextViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.delegate = self
            
            filtersViewController.initialFilters = currentFilters != nil ? currentFilters : defaultCurrentFilters
        } else {
            if businesses != nil {
                let mapViewController = nextViewController as! MapViewController
                mapViewController.businesses = self.businesses
            }
        }
    }
    
    func search(filters: [String: AnyObject]) {
        let categories = filters["categories"] as? [String]
        let deals = filters["deals"] as! Bool
        let distance = filters["distance"] as? Double
        var sortOrder = YelpSortMode.BestMatched
        if let sort = filters["sort"] as? Int {
            sortOrder =  YelpSortMode(rawValue: sort)!
        }
        var searchTerm = "Restaurants"
        if let searchText = searchBar!.text {
            searchTerm = searchText
        }
        var centerLocation: [Double]? = nil
        if let location = filters["location"] {
            centerLocation = location as! [Double]
        }
        
        filtersAppliedLabel.text = getFiltersText(currentFilters)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Business.searchWithTerm(searchTerm, sort: sortOrder, categories: categories, deals: deals, radius: distance, location: centerLocation) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.showError(businesses)
        }
        if businesses.count > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        currentFilters = filters
        search(filters)
    }

}
